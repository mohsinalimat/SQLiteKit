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

    public func createTable<T: SQLiteTable>(_ type: T.Type, createFlag: CreateFlags = .none) {
        
    }
    
    public func execute(_ sql: String, parameters: [Any]) {
        
    }
}


