//
//  SQLiteColumn.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation
import SQLite3

/// Represent SQLite Column Item
public struct SQLiteColumn: CustomStringConvertible {

    /// column field name
    public let name: String
    
    /// column field data type
    public let dataType: SQLiteDataType
    
    /// whether column is primary key, default to `false`
    public var primaryKey: Bool = false
    
    /// whether column should auto increase. Default to `false`
    public var autoIncrement: Bool = false
    
    /// whether should create index. Default to `false`
    public var createIndex: Bool = false
    
    public var nonnull: Bool = false
    
    public var unique: Bool = false
    
    /// Create a `SQLiteColumn` with name and dataType
    ///
    /// - Parameters:
    ///   - name: name of column
    ///   - dataType: dataTyp of column
    public init(name: String, dataType: SQLiteDataType) {
        self.name = name
        self.dataType = dataType
    }
    
    public var description: String {
        get {
            var sql = String(format: "%@ %@", name, dataType.rawValue)
            if primaryKey {
                sql += " PRIMARY KEY"
            }
            // only `INTEGER` type can apply AUTOINCREMENT
            if autoIncrement && dataType == .int {
                sql += " AUTOINCREMENT"
            }
            if nonnull {
                sql += " NOT NULL"
            }
            if unique {
                sql += " UNIQUE"
            }
            
            return sql
        }
    }
}
