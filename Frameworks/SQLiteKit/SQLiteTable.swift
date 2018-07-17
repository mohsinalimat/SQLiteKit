//
//  SQLiteTable.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/5/24.
//

import Foundation

public protocol SQLiteTable: class {
    
    init()
    
    static func sqliteAttributes() -> [SQLiteAttribute]
    
}

extension SQLiteTable {

}


public class SQLiteTableQuery<T: SQLiteTable> {
    
    public init(connection: SQLiteConnection) {
        
    }
}
