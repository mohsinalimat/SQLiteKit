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
    }
    
    fileprivate let dbPath: String
    fileprivate var un_fair_lock = os_unfair_lock()
    fileprivate let openFlags: OpenFlags
    fileprivate var _mappings: [String: TableMapping] = [:]
    
    let handle: DatabaseHandle
    
    public convenience init(databasePath: String) {
        self.init(databasePath: databasePath, openFlags: [.readWrite, .create])
    }
    
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

    public func createTable<T: SQLiteTable>(_ type: T.Type, createFlags: CreateFlags = .none) {
        let map = getMapping(of: type, createFlags: createFlags)
        if map.columns.count == 0 {
            return
        }
        
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
        } else {
            // migration
        }
    }
    
    public func getExistingColumns(tableName: String) -> [String] {
        //let query = String(format: "pragma table_info(%@)", tableName)
        return []
    }
    
    @discardableResult
    public func execute(_ query: String, parameters: [Any] = []) -> Int {
        let cmd = createCommand(query, parameters: parameters)
        let r = cmd.executeNonQuery()
        return r
    }
    
    public func query<T: SQLiteTable>(_ query: String, parameters: [Any]) -> [T] {
        return []
    }
    
    public func insert(_ obj: SQLiteTable?) -> Int {
        return insert(obj, extra: "")
    }
    
    public func insertOrReplace(_ obj: SQLiteTable?) -> Int {
        return insert(obj, extra: "OR REPLACE")
    }
    
    @discardableResult
    public func insert(_ obj: SQLiteTable?, extra: String) -> Int {
        guard let object = obj else {
            return 0
        }
        return 0
    }
    
    @discardableResult
    public func update(_ obj: SQLiteTable) -> Int {
        return 0
    }
    
    @discardableResult
    public func delete(_ obj: SQLiteTable) -> Int {
        return 0
    }
    
    public func deleteAll<T: SQLiteTable>(_ type: T.Type)  {
        
    }
    
    public func close() {
        
    }
    
    fileprivate func getMapping(of type: SQLiteTable.Type, createFlags: CreateFlags = .none) -> TableMapping {
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
    
    fileprivate func lock() {
        os_unfair_lock_lock(&un_fair_lock)
    }
    
    fileprivate func unlock() {
        os_unfair_lock_unlock(&un_fair_lock)
    }
}

extension SQLiteConnection {
    
    func migrateTable() {
        
    }
    
    func createCommand(_ cmdText: String, parameters: [Any]) -> SQLiteCommand {
        let cmd = SQLiteCommand(connection: self)
        cmd.commandText = cmdText
        for param in parameters {
            cmd.bind(param)
        }
        return cmd
    }
    
}



