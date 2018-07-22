//
//  TableMapping.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/16.
//

import Foundation

public enum Ordering {
    case ASC(String)
    case DESC(String)
    var declaration: String {
        switch self {
        case .ASC(let name):
            return "\(name) ASC"
        case .DESC(let name):
            return "\(name) DESC"
        }
    }
}

public struct TableMapping {
    
    public let tableName: String
    
    public let createFlags: SQLiteConnection.CreateFlags
    
    public let columns: [Column]
    
    public private(set) var insertColumns: [Column]
    
    public private(set) var insertOrReplaceColumns: [Column]
    
    public let queryByPrimaryKeySQL: String
    
    public var pk: Column?
    
    public var autoIncPK: Column?
    
    public var withoutRowId: Bool = false
    
    public var hasAutoIncPK: Bool {
        return autoIncPK != nil
    }
    
    public init(type: SQLiteTable.Type, createFlags: SQLiteConnection.CreateFlags = .none) {
        let attributes = type.attributes()
        
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
            // TODO: If we support nested table model, we should check
            //let m = Mirror(reflecting: child.value)
            //print(m.displayStyle)
        }
        columns = cols
        insertColumns = columns.filter { return $0.isAutoInc == false || !$0.ignored }
        insertOrReplaceColumns = columns.filter { return !$0.ignored }
        
        for c in cols {
            if c.isPK && c.isAutoInc {
                autoIncPK = c
            }
            if c.isPK {
                pk = c
            }
        }
        if let pk = pk {
            queryByPrimaryKeySQL = "SELECT * FROM \(tableName) WHERE \(pk.name) = ?"
        } else {
            queryByPrimaryKeySQL = "SELECT * FROM \(tableName) LIMIT 1"
        }
        withoutRowId = false
    }
    
    func findColumn(with name: String) -> Column? {
        return columns.first(where: { $0.name == name })
    }
    
    func setAutoIncPK(_ rowID: Int64) {
        // TODO: - Use reflection to set primary key value
    }
    
    public class Column {
        
        public let name: String
        
        public let value: Any
        
        public let isNullable: Bool
        
        public let isPK: Bool
        
        public let isAutoInc: Bool
        
        public let ignored: Bool
        
        public let columnType: Any.Type
        
        init(propertyInfo: Mirror.Child, attributes: [SQLiteAttribute]) {
            let columnName = propertyInfo.label!
            name = columnName
            value = propertyInfo.value
            isNullable = true
            let columnAttr = attributes.filter { $0.name == columnName }
            isPK = columnAttr.contains(where: { $0.attribute == Attribute.isPK })
            isAutoInc = columnAttr.contains(where: { $0.attribute == Attribute.autoInc })
            ignored = columnAttr.contains(where: { $0.attribute == Attribute.ignore })
            columnType = type(of: propertyInfo.value)
        }
        
        
        /// Using Mirror to refect object value
        ///
        /// - Parameter object: object
        /// - Returns: object value of the column
        func getValue(of object: SQLiteTable) -> Any {
            let mirror = Mirror(reflecting: object)
            return mirror.children.first(where: { $0.label == name })!.value
        }
        
    }
    
}

extension TableMapping.Column {
    
    var declaration: String {
        var decl = "'\(name)' \(SQLType) "
        if isPK {
            decl += "PRIMARY KEY "
        }
        if isAutoInc {
            decl += "AUTOINCREMENT "
        }
        if !isNullable {
            decl += "NOT NULL"
        }
        return decl
    }
    
    fileprivate var SQLType: String {
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
        
        let type = columnType
        for map in mappings {
            if map.value.contains(where: { type == $0 }) {
                return map.key
            }
        }
        return ""
    }
}
