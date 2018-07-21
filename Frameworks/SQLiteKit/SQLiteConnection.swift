//
//  SQLiteConnection.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation
import SQLite3

/// An open connection to a SQLite database.
public class SQLiteConnection {

    public enum ConnectionString {
        case inMemory
        case URL(URL)
    }
    
    /// Flags to create a SQLite database
    ///
    /// - none: Use the default creation options
    /// - implicitPK: Create a primary key index for a property called 'Id' (case-insensitive). This avoids the need for the [PrimaryKey] attribute.
    /// - implicitIndex: Create indices for properties ending in 'Id' (case-insensitive).
    /// - allImplicit: Create a primary key for a property called 'Id' and create an indices for properties ending in 'Id' (case-insensitive).
    /// - autoIncPK: Force the primary key property to be auto incrementing. This avoids the need for the [AutoIncrement] attribute. The primary key property on the class should have type int or long.
    /// - fullTextSearch3: Create virtual table using FTS3
    /// - fullTextSearch4: Create virtual table using FTS4
    public enum CreateFlags: Int {
        case none = 0x000
        case implicitPK = 0x001
        case implicitIndex = 0x002
        case allImplicit = 0x003
        case autoIncPK = 0x004
        case fullTextSearch3 = 0x100
        case fullTextSearch4 = 0x200
    }
    
    public struct OpenFlags: OptionSet {

        public let rawValue: Int32
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        public static let readOnly = OpenFlags(rawValue: 1)
        public static let readWrite = OpenFlags(rawValue: 2)
        public static let create = OpenFlags(rawValue: 4)
        public static let noMutex = OpenFlags(rawValue: 0x8000)
        public static let fullMutex = OpenFlags(rawValue: 0x10000)
        public static let sharedCache = OpenFlags(rawValue: 0x20000)
        public static let privateCache = OpenFlags(rawValue: 0x40000)
        public static let protectionComplete = OpenFlags(rawValue: 0x00100000)
        public static let protectionCompleteUnlessOpen = OpenFlags(rawValue: 0x00200000)
        public static let protectionCompleteUntilFirstUserAuthentication = OpenFlags(rawValue: 0x00300000)
        public static let protectionNone = OpenFlags(rawValue: 0x00400000)
    }
    
    public enum CreateTableResult {
        case created
        case migrated
        case noneColumnsFound
    }
    
    /// SQLite libray version number.
    public let libVersionNumber: Int
    
    /// Whether trace debug information
    public var debugTrace: Bool = false
    public var traceHandler: ((String) -> Void)?
    
    fileprivate let dbPath: String
    fileprivate let _open: Bool
    fileprivate var un_fair_lock = os_unfair_lock()
    fileprivate let openFlags: OpenFlags
    fileprivate var _mappings: [String: TableMapping] = [:]
    fileprivate var _insertCommandMap: [String: PreparedSqliteInsertCommand] = [:]
    
    internal let handle: SQLiteDatabaseHandle
    
    /// Constructs a new SQLiteConnection and opens a SQLite database specified by databasePath.
    ///
    /// - Parameter databasePath: Specifies the path to the database file.
    public convenience init(databasePath: String) {
        self.init(databasePath: databasePath, openFlags: [.readWrite, .create])
    }
    
    /// Constructs a new SQLiteConnection and opens a SQLite database specified by databasePath.
    ///
    /// - Parameters:
    ///   - databasePath: Specifies the path to the database file.
    ///   - openFlags: Flags controlling how the connection should be opened.
    public init(databasePath: String, openFlags: OpenFlags) {
        self.dbPath = databasePath
        self.openFlags = openFlags
        self.libVersionNumber = SQLite3.libVersionNumber()
        var dbHandle: SQLiteDatabaseHandle?
        let _ = SQLite3.open(filename: dbPath, db: &dbHandle, flags: openFlags)
        handle = dbHandle!
        _open = true
    }
    
    deinit {
        SQLite3.close(handle)
    }

    /// Executes a "drop table" on the database.  This is non-recoverable.
    ///
    /// - Parameter type: Type to reflect to a database table.
    /// - Returns: Whether the table was dropped
    @discardableResult
    public func dropTable<T: SQLiteTable>(_ type: T.Type) -> Int {
        let map = getMapping(of: type)
        let sql = "drop table if exists \(map.tableName)"
        return execute(sql)
    }
    
    /// Executes a "create table if not exists" on the database. It also
    /// creates any specified indexes on the columns of the table. It uses
    /// a schema automatically generated from the specified type. You can
    /// later access this schema by calling GetMapping.
    ///
    /// - Parameters:
    ///   - type: Type to reflect to a database table
    ///   - createFlags: Optional flags allowing implicit PK and indexes based on naming conventions
    /// - Returns: Whether the table was created or migrated.
    @discardableResult
    public func createTable<T: SQLiteTable>(_ type: T.Type, createFlags: CreateFlags = .none) -> CreateTableResult {
        let map = getMapping(of: type, createFlags: createFlags)
        if map.columns.count == 0 {
            return CreateTableResult.noneColumnsFound
        }
        
        let result: CreateTableResult
        let existingCols = getExistingColumns(tableName: map.tableName)
        if existingCols.count == 0 {
            let fts3: Bool = (createFlags.rawValue & CreateFlags.fullTextSearch3.rawValue) != 0
            let fts4: Bool = (createFlags.rawValue & CreateFlags.fullTextSearch4.rawValue) != 0
            let fts = fts3 || fts4
            let virtual = fts ? "VIRTUAL ": ""
            
            var using = ""
            if fts3 {
                using = "USING FTS3"
            } else if fts4 {
                using = "USING FTS4"
            }
            var sql = "CREATE \(virtual)TABLE IF NOT EXISTS \(map.tableName) \(using)("
            let declarationList = map.columns.map { return SQLiteORM.sqlDeclaration(of: $0) }
            let declaration = declarationList.joined(separator: ",")
            sql += declaration
            sql += ")"
            if map.withoutRowId {
                sql += " WITHOUT ROWID"
            }
            execute(sql)
            result = .created
        } else {
            // do the migration
            migrateTable(map, existingCols: existingCols)
            result = .migrated
        }
        // TODO: - create index
        return result
    }
    
    // MARK: - Index
    
    /// Creates an index for the specified table and columns.
    ///
    /// - Parameters:
    ///   - indexName: Name of the index to create
    ///   - tableName: Name of the database table
    ///   - columnName: Name of the column to index
    ///   - unique: Whether the index should be unique
    /// - Returns: result of create index
    @discardableResult
    public func createIndex(_ indexName: String, tableName: String, columnName: String, unique: Bool = false) -> Int {
        return createIndex(indexName, tableName: tableName, columnNames: [columnName], unique: unique)
    }
    
    /// Creates an index for the specified table and columns.
    ///
    /// - Parameters:
    ///   - indexName: Name of the index to create
    ///   - tableName: Name of the database table
    ///   - columnNames: Name of the columns to index
    ///   - unique: Whether the index should be unique
    /// - Returns: result of create index
    @discardableResult
    public func createIndex(_ indexName: String, tableName: String, columnNames: [String], unique: Bool = false) -> Int {
        let columns = columnNames.joined(separator: ",")
        let u = unique ? "UNIQUE": ""
        let sql = String(format: "CREATE %@ INDEX IF NOT EXISTS %@ ON %@(%@)", columns, indexName, u, tableName)
        return execute(sql)
    }
    
    /// Creates a SQLiteCommand given the command text (SQL) with arguments. Place a '?'
    /// in the command text for each of the arguments and then executes that command.
    /// Use this method instead of Query when you don't expect rows back. Such cases include
    /// INSERTs, UPDATEs, and DELETEs.
    ///
    /// - Parameters:
    ///   - query: The fully escaped SQL.
    ///   - parameters: Arguments to substitute for the occurences of '?' in the query.
    /// - Returns: The number of rows modified in the database as a result of this execution.
    @discardableResult
    public func execute(_ query: String, parameters: [Any] = []) -> Int {
        let cmd = createCommand(query, parameters: parameters)
        let r = cmd.executeNonQuery()
        return r
    }
    
    // MARK: - Query
    
    public func query<T>(_ query: String, parameters: [Any] = []) -> [T] where T: SQLiteTable {
        let cmd = createCommand(query, parameters: parameters)
        return cmd.executeQuery()
    }
    
    public func find<T: SQLiteTable>(_ pk: Any) -> T? {
        let map = getMapping(of: T.self)
        return query(map.queryByPrimaryKeySQL, parameters: [pk]).first
    }
    
    
    /// Attempts to retrieve the first object that matches the query from the table associated with the specified type.
    ///
    /// - Parameters:
    ///   - sql: The fully escaped SQL.
    ///   - parameters: Arguments to substitute for the occurences of '?' in the query.
    /// - Returns: The object that matches the given predicate or `nil` if not found.
    public func findWithQuery<T: SQLiteTable>(_ sql: String, parameters: [Any]) -> T? {
        return query(sql, parameters: parameters).first
    }
    
    /// Returns a queryable interface to the table represented by the given type.
    ///
    /// - Returns: A queryable object that is able to translate Where, OrderBy, and Take queries into native SQL.
    public func table<T>() -> SQLiteTableQuery<T> where T: SQLiteTable {
        let map = getMapping(of: T.self)
        return SQLiteTableQuery<T>(connection: self, table: map)
    }
    
    
    /// Returns a queryable interface to the table represented by the given type.
    ///
    /// - Parameter Type to reflect to a database table
    /// - Returns: A queryable object that is able to translate Where, OrderBy, and Take queries into native SQL.
    public func table<T>(of type: SQLiteTable.Type) -> SQLiteTableQuery<T> where T: SQLiteTable {
        let map = getMapping(of: type)
        return SQLiteTableQuery<T>(connection: self, table: map)
    }
    
    // MARK: - Transcation
    
    public func beginTranscation() {
        
    }
    
    public func rollback() {
        
    }
    
    public func commitTranscation() {
        
    }
    
    public func runInTranscation(_ block: () -> Void) {
        
    }
    
    // MARK: - Insert
    
    /// Inserts the given object (and updates its auto incremented primary key if it has one).
    /// The return value is the number of rows added to the table.
    ///
    /// - Parameter obj: The object to insert.
    /// - Returns: The number of rows added to the table.
    @discardableResult
    public func insert(_ obj: SQLiteTable?) -> Int {
        return insert(obj, extra: "")
    }
    
    
    /// Inserts the given object (and updates its auto incremented primary key if it has one).
    /// The return value is the number of rows added to the table.
    /// If a UNIQUE constraint violation occurs with some pre-existing object, this function deletes the old objects
    ///
    /// - Parameter obj: The object to insert.
    /// - Returns: The number of rows modified.
    @discardableResult
    public func insertOrReplace(_ obj: SQLiteTable?) -> Int {
        return insert(obj, extra: "OR REPLACE")
    }
    
    
    /// Inserts the given object (and updates its
    /// auto incremented primary key if it has one).
    /// The return value is the number of rows added to the table.
    ///
    /// - Parameters:
    ///   - obj: The object to insert.
    ///   - extra: Literal SQL code that gets placed into the command. INSERT {extra} INTO ...
    /// - Returns: The number of rows added to the table.
    @discardableResult
    public func insert(_ obj: SQLiteTable?, extra: String) -> Int {
        guard let object = obj else {
            return 0
        }
        let map = getMapping(of: object.mapType)
        let isReplacing = extra.uppercased() == "OR REPLACE"
        let columns = isReplacing ? map.insertOrReplaceColumns: map.insertColumns
        
        let values: [Any] = columns.map { return $0.getValue(of: object) }
        let cmd = getInsertCommand(map: map, extra: extra)
        let rows = cmd.executeNonQuery(values)
        if map.hasAutoIncPK {
            let id = SQLite3.lastInsertRowid(handle)
            map.setAutoIncPK(id)
        }
        return rows
    }
    
    
    /// Inserts all specified objects.
    ///
    /// - Parameters:
    ///   - objects: Objects to insert
    ///   - inTranscation: A boolean indicating if the inserts should be wrapped in a transaction.
    /// - Returns: The number of rows added to the table.
    @discardableResult
    public func insertAll(_ objects: [SQLiteTable], inTranscation: Bool = false) -> Int {
        var result = 0
        if inTranscation {
            
        } else {
            for obj in objects {
                result += insert(obj)
            }
        }
        return result
    }
    
    // MARK: - Update
    
    /// Updates all of the columns of a table using the specified object
    /// except for its primary key.
    /// The object is required to have a primary key.
    ///
    /// - Parameter obj: The object to update. It must have a primary key designated using the Attribute.isPK.
    /// - Returns: The number of rows updated.
    @discardableResult
    public func update(_ obj: SQLiteTable) -> Int {
        return 0
    }
    
    @discardableResult
    public func update<T: SQLiteTable>(_ obj: T) -> Int {
        let map = getMapping(of: T.self)
        guard let pk = map.pk else {
            return 0
        }
        //let pk = map.pk
        let cols = map.columns.filter { return $0.isPK == false }
        let sets = cols.map { return "\($0.name) = ?" }.joined(separator: ",")
        var values: [Any] = cols.map { return $0.getValue(of: obj) }
        values.append(pk.getValue(of: obj))
        let sql = String(format: "UPDATE %@ SET %@ WHERE %@ = ?", map.tableName, sets, pk.name)
        return execute(sql, parameters: values)
    }
    
    // MARK: - Delete
    
    /// Deletes the given object from the database using its primary key.
    ///
    /// - Parameter obj: The object to delete. It must have a primary key designated using the Attribute.isPK.
    /// - Returns: The number of rows deleted.
    @discardableResult
    public func delete(_ obj: SQLiteTable) -> Int {
        let map = getMapping(of: obj.mapType)
        guard let pk = map.pk else {
            return 0
        }
        let sql = "DELETE FROM \(map.tableName) WHERE \(pk.name) = ?"
        return execute(sql, parameters: [pk.value])
    }
    
    
    /// Delete all table data
    ///
    /// - Parameter type: Type to reflect to a database table.
    /// - Returns: Rows deleted
    @discardableResult
    public func deleteAll<T: SQLiteTable>(_ type: T.Type) -> Int {
        let map = getMapping(of: T.self)
        return deleteAll(map: map)
    }
    
    @discardableResult
    fileprivate func deleteAll(map: TableMapping) -> Int {
        let sql = "DELETE FROM \(map.tableName)"
        return execute(sql)
    }
    
    public func close() {
        
    }
    
    public func executeScalar<T: SQLiteTable>(_ query: String, parameters: [Any] = []) -> T {
        
        return T()
    }
}

extension SQLiteConnection {
    
    internal func getMapping(of type: SQLiteTable.Type, createFlags: CreateFlags = .none) -> TableMapping {
        let key = String(describing: type)
        var map: TableMapping
        lock()
        if let oldMap = _mappings[key] {
            if createFlags != .none && createFlags != oldMap.createFlags {
                map = TableMapping(type: type, createFlags: createFlags)
                _mappings[key] = map
            } else {
                map = oldMap
            }
        } else {
            map = TableMapping(type: type)
            _mappings[key] = map
        }
        unlock()
        return map
    }
    
    fileprivate func migrateTable(_ map: TableMapping, existingCols: [ColumnInfo]) {
        var newCols: [TableMapping.Column] = []
        for column in map.columns {
            if let _ = existingCols.first(where: { $0.name == column.name }) {
                continue
            }
            newCols.append(column)
        }
        for p in newCols {
            let sql = "ALTER TABLE \(map.tableName) ADD COLUMN \(SQLiteORM.sqlDeclaration(of: p))"
            execute(sql)
        }
    }
    
    fileprivate func getExistingColumns(tableName: String) -> [ColumnInfo] {
        let sql = String(format: "pragma table_info(%@)", tableName)
        return query(sql)
    }
    
    func createCommand(_ cmdText: String, parameters: [Any]) -> SQLiteCommand {
        let cmd = SQLiteCommand(connection: self)
        cmd.commandText = cmdText
        for param in parameters {
            cmd.bind(param)
        }
        return cmd
    }
    
    fileprivate func getInsertCommand(map: TableMapping, extra: String) -> PreparedSqliteInsertCommand {
        var columns = map.insertColumns
        let sql: String
        if columns.count == 0 && map.columns.count == 1 && map.columns.first?.isAutoInc == true {
            sql = "INSERT \(extra) INTO \(map.tableName) DEFAULT VALUES"
        } else {
            if extra.uppercased() == "OR REPLACE" {
                columns = map.insertOrReplaceColumns
            }
            let keys = columns.map { return $0.name }.joined(separator: ",")
            let values = [String].init(repeating: "?", count: columns.count).joined(separator: ",")
            sql = "INSERT \(extra) INTO \(map.tableName) (\(keys)) VALUES (\(values))"
        }
        return PreparedSqliteInsertCommand(connection: self, commandText: sql)
    }
    
    fileprivate func lock() {
        os_unfair_lock_lock(&un_fair_lock)
    }
    
    fileprivate func unlock() {
        os_unfair_lock_unlock(&un_fair_lock)
    }
}

fileprivate class ColumnInfo: SQLiteTable {
    
    static func sqliteAttributes() -> [SQLiteAttribute] {
        return []
    }
    
    public let name: String
    
    public let notnull: Int
    
    required init() {
        name = ""
        notnull = 0
    }
}
