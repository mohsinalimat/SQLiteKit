//
//  SQLiteDataType.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation

public enum SQLiteDataType: String {
    case null = "NULL"
    case time = "TIMESTAMP"
    case string = "VARCHAR(50)"
    case float = "REAL"
    case int = "INTEGER"
    case text = "TEXT"
    case data = "BLOB"
}
