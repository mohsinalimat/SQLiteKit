//
//  SQLiteCommand.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation

struct Binding {
    
    public let name: String
    
    public let value: Any?
    
    public var index: Int = 0
    
    init(name: String, value: Any?) {
        self.name = name
        self.value = value
        self.index = 0
    }
}

public class SQLiteCommand {
    
    fileprivate let conn: SQLiteConnection
    
    fileprivate var bindings: [Binding] = []
    
    public var commandText: String = ""
    
    init(connection: SQLiteConnection) {
        conn = connection
    }
    
    func bind(_ name: String, value: Any) {
        let binding = Binding(name: name, value: value)
        bindings.append(binding)
    }
    
    func bind(value: Any) {
        //bind(<#T##name: String##String#>, value: <#T##Any#>)
    }
    
    func bindAll(_ stmt: Statement) {
        var index = 1
        for var bind in bindings {
            if let value = bind.value {
                
            }
            bind.index = SQLite3.bindParameterIndex(stmt, name: bind.name)
        }
    }
    
    static func bindParameter(_ stmt: Statement, index: Int, value: Any?) {
        if let value = value {
            
        } else {
            SQLite3.bindNull(stmt, index: index)
        }
        
    }
    
    func readColumn(_ stmt: Statement, index: Int, columnType: SQLite3.ColumnType) -> Any? {
        if columnType == .Null {
            return nil
        }
        return nil
    }
    
//    func prepare() -> Statement {
//        SQLite3.prepare(dbHandle: conn, SQL: <#T##String#>)
//    }
    
//    func executeScalar<T>() -> T {
//
//    }
    
}
