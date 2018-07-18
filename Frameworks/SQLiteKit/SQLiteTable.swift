//
//  SQLiteTable.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/5/24.
//

import Foundation

/// Type to reflect to a database table
public protocol SQLiteTable: class, Codable {
    
    init()

    /// specifiy column attributes of a table, eg: isPK
    ///
    /// - Returns: column attributes
    static func sqliteAttributes() -> [SQLiteAttribute]
    
}

extension SQLiteTable {

    /// return mapping type of SQLiteTable
    internal var mapType: SQLiteTable.Type {
        let mirror = Mirror(reflecting: self)
        return mirror.subjectType as! SQLiteTable.Type
    }
}


public class SQLiteTableQuery<T: SQLiteTable> {
    
    private let conn: SQLiteConnection
    private let table: TableMapping
    
    public init(connection: SQLiteConnection, table: TableMapping) {
        self.conn = connection
        self.table = table
    }
    
    public func count() -> Int {
        return 0
    }
    
    private func generateCommand(_ selection: String) -> SQLiteCommand {
        
        let cmdText = "SELECT \(selection) FROM \(table.tableName)"
        let args: [Any] = []
        return conn.createCommand(cmdText, parameters: args)
    }
}
