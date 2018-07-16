//
//  SQLiteAttribute.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/16.
//

import Foundation

public struct SQLiteAttribute {
    public let name: String
    public let attribute: Attribute
    public init(name: String, attribute: Attribute) {
        self.name = name
        self.attribute = attribute
    }
}

public struct Attribute: OptionSet {
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none = Attribute(rawValue: 1 << 0)
    public static let isPK = Attribute(rawValue: 1 << 1)
    public static let autoInc = Attribute(rawValue: 1 << 2)
    public static let nullable = Attribute(rawValue: 1 << 3)
    public static let indexed = Attribute(rawValue: 1 << 4)
    
    /// specify table name
    public static let tableName = Attribute(rawValue: 1 << 5)
    
    /// member that defins when `ignore` will not create column
    public static let ignore = Attribute(rawValue: 1 << 6)
}
