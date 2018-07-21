//
//  SQLiteORM.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/18.
//

import Foundation

class SQLiteORM {
    
    class func sqlDeclaration(of column: TableMapping.Column) -> String {
        var decl = "'\(column.name)' \(sqlType(of: column)) "
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
    
    class func sqlType(of column: TableMapping.Column) -> String {
        
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
