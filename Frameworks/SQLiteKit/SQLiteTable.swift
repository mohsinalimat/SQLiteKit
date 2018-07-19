//
//  SQLiteTable.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/5/24.
//

import Foundation

/// Type to reflect to a database table
public protocol SQLiteTable: class, Codable {
    
    
    /// Required initializer. used for Mirror reflecting of Object ORM
    init()

    /// Specifiy column attributes of a table, eg: isPK
    ///
    /// - Returns: column attributes
    static func sqliteAttributes() -> [SQLiteAttribute]
    
}

extension SQLiteTable {

    /// Return mapping type of SQLiteTable
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
    
    
    /// Execute SELECT COUNT(*) FROM `Table`
    public var count: Int {
        let c: Int = generateCommand("COUNT(*)").executeScalar() ?? 0
        return c
    }
    
    private func generateCommand(_ selection: String) -> SQLiteCommand {
        
        let cmdText = "SELECT \(selection) FROM \(table.tableName)"
        let args: [Any] = []
        return conn.createCommand(cmdText, parameters: args)
    }
    
    /// Execute SELECT * FROM `Table`
    ///
    /// - Returns: All rows
    public func list() -> [T] {
        return generateCommand("*").executeQuery()
    }
    
    public func filter<T: SQLiteTable>(_ isIncluded: (T) -> Bool) -> [T] {
        return []
    }
    
    public func filter(_ isIncluded: Bool) {
        
    }
    
    public func orderBy() -> SQLiteTableQuery<T> {
        let q: SQLiteTableQuery<T> = clone()
        return q
    }
    
    func clone<T: SQLiteTable>() -> SQLiteTableQuery<T> {
        let query = SQLiteTableQuery<T>(connection: conn, table: table)
        
        return query
    }
}
