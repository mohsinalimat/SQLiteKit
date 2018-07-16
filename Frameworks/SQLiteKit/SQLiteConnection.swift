//
//  SQLiteConnection.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation
import SQLite3

public class SQLiteConnection {

    public enum CreateFlags {
        case none
        case implicitPK
        case implicitIndex
        case allImplicit
        case autoIncPK
        case fullTextSearch3
        case FullTextSearch4
    }
    
    public enum CreateTableResult {
        case created, migrated
    }
    
    fileprivate let dbPath: String
    
    fileprivate let openFlags: SQLiteOpenFlags
    
    let handle: DatabaseHandle
    
    public convenience init(databasePath: String) {
        self.init(databasePath: databasePath, openFlags: [.readWrite, .create])
    }
    
    public init(databasePath: String, openFlags: SQLiteOpenFlags) {
        self.dbPath = databasePath
        self.openFlags = openFlags
        
        var dbHandle: DatabaseHandle?
        let _ = SQLite3.open(filename: dbPath, db: &dbHandle, flags: .create)
        handle = dbHandle!
    }
    
    deinit {
        SQLite3.close(handle)
    }

    public func createTable<T: SQLiteTable>(_ type: T.Type, createFlag: CreateFlags = .none) {
        let mapping = Mirror(reflecting: T.self)
        
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

