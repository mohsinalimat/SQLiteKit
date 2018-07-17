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
    
    public enum CreateTableResult {
        case created, migrated
    }
    
    fileprivate let dbPath: String
    fileprivate var un_fair_lock = os_unfair_lock()
    fileprivate let openFlags: SQLiteOpenFlags
    fileprivate var _mappings: [String: TableMapping] = [:]
    
    let handle: DatabaseHandle
    
    public convenience init(databasePath: String) {
        self.init(databasePath: databasePath, openFlags: [.readWrite, .create])
    }
    
    public init(databasePath: String, openFlags: SQLiteOpenFlags) {
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
            if map.withoutRowId {
                sql += " without rowid"
            }
            
        } else {
            
        }
        
        
        
    }
    
    public func getExistingColumns(tableName: String) -> [String] {
        //let query = String(format: "pragma table_info(%@)", tableName)
        return []
    }
    
    public func execute(_ query: String, parameters: [Any]) {
        
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



