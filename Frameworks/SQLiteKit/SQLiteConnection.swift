//
//  SQLiteConnection.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation
import SQLite3

class SQLiteConnection {
    
    fileprivate let dbPath: String
    
    fileprivate let openFlags: SQLiteOpenFlags
    
    init(databasePath: String) {
        self.dbPath = databasePath
        self.openFlags = [.readWrite, .create]
    }
    
    init(databasePath: String, openFlags: SQLiteOpenFlags) {
        self.dbPath = databasePath
        self.openFlags = openFlags
    }
    
}


