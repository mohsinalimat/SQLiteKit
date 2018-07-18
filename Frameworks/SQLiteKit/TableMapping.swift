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
    public private(set) var insertColumns: [Column]
    public private(set) var insertOrReplaceColumns: [Column]
    
    public var pk: Column?
    
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
        let mirror = Mirror(reflecting: type.init())
        for child in mirror.children {
            let col = Column(propertyInfo: child, attributes: attributes)
            cols.append(col)
        }
        columns = cols
        insertColumns = columns.filter { return $0.isAutoInc == false }
        insertOrReplaceColumns = columns
        
        for col in cols {
            if col.isPK {
                pk = col
            }
        }
        withoutRowId = false
    }
    
    func findColumn(with name: String) -> Column? {
        return columns.first(where: { $0.name == name })
    }
    
    public class Column {
        
        public let name: String
        
        public let value: Any
        
        public let isNullable: Bool
        
        public let isPK: Bool
        
        public let isAutoInc: Bool
        
        public let columnType: Any.Type
        
        init(propertyInfo: Mirror.Child, attributes: [SQLiteAttribute]) {
            let columnName = propertyInfo.label!
            name = columnName
            value = propertyInfo.value
            isNullable = true
            let columnAttr = attributes.filter { $0.name == columnName }
            isPK = columnAttr.first(where: { $0.attribute == Attribute.isPK }) != nil
            isAutoInc = columnAttr.first(where: { $0.attribute == Attribute.autoInc }) != nil
            columnType = type(of: propertyInfo.value)
        }
        
        func getValue(of object: SQLiteTable) -> Any {
            let mirror = Mirror(reflecting: object)
            return mirror.children.first(where: { $0.label == name })!.value
        }
        
    }
    
    class ORM {
        
        class func sqlDeclaration(of column: Column) -> String {
            var decl = "'\(column.name)' \(sqlType(of: column))"
            if column.isPK {
                decl += "PRIMARY KEY "
            }
            if column.isAutoInc {
                decl += "AUTOINCREMENT "
            }
            if !column.isNullable {
                decl += "NOT NULL"
            }
            return decl
        }
        
        class func sqlType(of column: Column) -> String {
            
            let mappings: [String: [Any.Type]] = [
                "INTEGER": [
                    Int.self, Int?.self,
                    Bool.self, Bool?.self
                ],
                "REAL": [
                    Float.self, Float?.self,
                    Date.self, Date?.self
                ],
                "TEXT": [
                    String.self, String?.self,
                    URL.self, URL?.self
                ],
                "BLOB": [
                    Data.self, Data?.self,
                    [UInt8].self, [UInt8]?.self
                ]
            ]
            
            let type = column.columnType
            
            for map in mappings {
                if map.value.contains(where: { type == $0 }) {
                    return map.key
                }
            }
            
            return ""
        }
    }
}
