//
//  SQLiteColumn.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation
import SQLite3

public struct ColumnAttribute {
    public let name: String
    public let info: ColumnInfo
    public init(name: String, info: ColumnInfo) {
        self.name = name
        self.info = info
    }
}

public struct ColumnInfo: OptionSet {
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none = ColumnInfo(rawValue: 1 << 0)
    public static let isPK = ColumnInfo(rawValue: 1 << 1)
    public static let autoInc = ColumnInfo(rawValue: 1 << 2)
    public static let nullable = ColumnInfo(rawValue: 1 << 3)
    public static let indexed = ColumnInfo(rawValue: 1 << 4)
}

public struct SQLiteColumn {

    
}
