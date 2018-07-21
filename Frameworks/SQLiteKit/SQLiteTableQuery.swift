//
//  SQLiteTableQuery.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/21.
//

import Foundation

/// A query
public class SQLiteTableQuery<T: SQLiteTable> {
    
    private let conn: SQLiteConnection
    private let table: TableMapping
    private var _limit: Int?
    private var _offset: Int?
    private var _orderBys: [Ordering]?
    
    public init(connection: SQLiteConnection, table: TableMapping) {
        self.conn = connection
        self.table = table
    }
    
    /// Execute SELECT COUNT(*) FROM `Table`
    public var count: Int {
        do {
            let c: Int = try generateCommand("COUNT(*)").executeScalar() ?? 0
            return c
        } catch {
            print(error)
        }
        return 0
    }
    
    private func generateCommand(_ selection: String) -> SQLiteCommand {
        var cmdText = "SELECT \(selection) FROM \(table.tableName)"
        
        if let limit = _limit {
           cmdText += " LIMIT \(limit)"
        }
        if let offset = _offset {
            if _limit == nil {
                cmdText = " LIMIT -1"
            }
            cmdText += " OFFSET \(offset)"
        }
        let args: [Any] = []
        return conn.createCommand(cmdText, parameters: args)
    }
    
    /// Execute SELECT * FROM `Table`
    ///
    /// - Returns: All rows
    public func toList() -> [T] {
        return generateCommand("*").executeQuery()
    }
    
    public func filter<T: SQLiteTable>(_ isIncluded: (T) -> Bool) -> [T] {
        return []
    }
    
    public func filter(_ isIncluded: Bool) {
        
    }
    
    /// Filter using NSPredicate.
    /// NOTE: Key used in predicate must be one of properties name within your table model.
    ///
    /// - Parameter predicate: predicate
    /// - Returns: All objects that match the predicate
    public func filter<T: SQLiteTable>(using predicate: NSPredicate) -> [T] {
        let predication = predicate.predicateFormat
        let cmdText = "SELECT * FROM \(table.tableName) WHERE \(predication)"
        return conn.createCommand(cmdText, parameters: []).executeQuery()
    }
    
    public func limit<T: SQLiteTable>(_ limit: Int) -> SQLiteTableQuery<T> {
        let q: SQLiteTableQuery<T> = clone()
        q._limit = limit
        return q
    }
    
    public func `where`(_ condition: String) -> SQLiteTableQuery<T> {
        let q: SQLiteTableQuery<T> = clone()
        return q
    }
    
    public func orderBy(_ order: Ordering) -> SQLiteTableQuery<T> {
        let q: SQLiteTableQuery<T> = clone()
        return q
    }
    
    fileprivate func clone<T: SQLiteTable>() -> SQLiteTableQuery<T> {
        let query = SQLiteTableQuery<T>(connection: conn, table: table)
        query._limit = _limit
        query._offset = _offset
        return query
    }
}

