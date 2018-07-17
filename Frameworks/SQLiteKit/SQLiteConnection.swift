//
//  SQLiteConnection.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation
import SQLite3

public class SQLiteConnection {

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
        case created, migrated
        case noneColumnsFound
    }
    
    fileprivate let dbPath: String
    fileprivate var un_fair_lock = os_unfair_lock()
    fileprivate let openFlags: OpenFlags
    fileprivate var _mappings: [String: TableMapping] = [:]
    
    let handle: DatabaseHandle
    
    
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
        
        var dbHandle: DatabaseHandle?
        let _ = SQLite3.open(filename: dbPath, db: &dbHandle, flags: openFlags)
        handle = dbHandle!
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
            var sql = "CREATE \(virtual) TABLE IF NOT EXISTS \(map.tableName) \(using)("
            let declarationList = map.columns.map { return TableMapping.ORM.sqlDeclaration(of: $0) }
            let declaration = declarationList.joined(separator: ",")
            sql += declaration
            sql += ")"
            print(sql)
            if map.withoutRowId {
                sql += " without rowid"
            }
            execute(sql)
            result = .created
        } else {
            // do the migration
            migrateTable(map, existingCols: existingCols)
            result = .migrated
        }
        return result
    }
    
    @discardableResult
    public func createIndex(_ indexName: String, tableName: String, columnName: String, unique: Bool = false) -> Int {
        return createIndex(indexName, tableName: tableName, columnNames: [columnName], unique: unique)
    }
    
    @discardableResult
    public func createIndex(_ indexName: String, tableName: String, columnNames: [String], unique: Bool = false) -> Int {
        let columns = columnNames.joined(separator: ",")
        let u = unique ? "unique": ""
        let sql = String(format: "CREATE %@ INDEX IF NOT EXISTS %@ ON %@(%@)", columns, indexName, u, tableName)
        return execute(sql)
    }
    
    public func getExistingColumns(tableName: String) -> [String] {
        //let query = String(format: "pragma table_info(%@)", tableName)
        return []
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
    
    public func query<T: SQLiteTable>(_ query: String, parameters: [Any]) -> [T] {
        let cmd = createCommand(query, parameters: parameters)
        
        return []
    }
    
    // MARK: - Transcation
    
    public func beginTranscation() {
        
    }
    
    public func rollback() {
        
    }
    
    public func commitTranscation() {
        
    }
    
    // MARK: - Insert
    
    /// Inserts the given object (and updates its
    /// auto incremented primary key if it has one).
    /// The return value is the number of rows added to the table.
    ///
    /// - Parameter obj: The object to insert.
    /// - Returns: The number of rows added to the table.
    @discardableResult
    public func insert(_ obj: SQLiteTable?) -> Int {
        return insert(obj, extra: "")
    }
    
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
        print(map)
        return 0
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
        let sql = "delete from \(map.tableName) where \(pk.name) = ?"
        return execute(sql, parameters: [pk.value])
    }
    
    public func deleteAll<T: SQLiteTable>(_ type: T.Type)  {
        
    }
    
    public func close() {
        
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
    
    fileprivate func migrateTable(_ map: TableMapping, existingCols: [String]) {
        var newCols: [TableMapping.Column] = []
        for column in map.columns {
            if existingCols.contains(column.name) {
                continue
            }
            newCols.append(column)
        }
        for p in newCols {
            let sql = "alter table \(map.tableName) add column \(TableMapping.ORM.sqlDeclaration(of: p))"
            execute(sql)
        }
        print(newCols)
    }
    
    fileprivate func createCommand(_ cmdText: String, parameters: [Any]) -> SQLiteCommand {
        let cmd = SQLiteCommand(connection: self)
        cmd.commandText = cmdText
        for param in parameters {
            cmd.bind(param)
        }
        return cmd
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
