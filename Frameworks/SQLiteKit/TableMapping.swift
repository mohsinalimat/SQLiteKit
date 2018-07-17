//
//  TableMapping.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/16.
//

import Foundation

public struct TableMapping {
    
    public let tableName: String
    
    public let createFlags: SQLiteConnection.CreateFlags
    
    public let columns: [Column]
    
    public var withoutRowId: Bool = false
    
    public init(type: SQLiteTable.Type, createFlags: SQLiteConnection.CreateFlags = .none) {
        let attributes = type.sqliteAttributes()
        if let nameAttribute = attributes.first(where: { $0.attribute == .tableName }) {
            tableName = nameAttribute.name
        } else {
            tableName = String(describing: type.self)
        }
        self.createFlags = createFlags
        
        var cols: [Column] = []
        let mirror = Mirror(reflecting: type)
        for child in mirror.children {
            let col = Column(propertyInfo: child, attributes: attributes)
            cols.append(col)
        }
        columns = cols
        
        withoutRowId = false
    }
    
    
    public class Column {
        
        public let name: String
        
        public let isNullable: Bool
        
        public let isPK: Bool
        
        public let isAutoInc: Bool
        
        public let columnType: Any.Type
        
        init(propertyInfo: Mirror.Child, attributes: [SQLiteAttribute]) {
            name = ""
            isNullable = false
            isPK = false
            isAutoInc = false
            columnType = type(of: propertyInfo.value)
        }
        
    }
    
    class ORM {
        
        class func sqlType(of column: Column) -> String {
            
            let mappings: [String: [Any.Type]] = [
                "integer": [
                    Int.self, Int?.self,
                    Bool.self, Bool?.self
                ],
                "float": [
                    Float.self, Float?.self
                ],
                "text": [
                    String.self, String?.self,
                    URL.self, URL?.self
                ],
                "blob": [
                    Data.self, Data?.self,
                    [UInt8].self, [UInt8]?.self
                ]
            ]
            
            let type = column.columnType
            
            for map in mappings {
                if map.value.contains(where: { type == $0 }) {
                    break
                }
            }
            
            return ""
        }
    }
}
