//
//  SQLiteCommand.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation

public class SQLiteCommand {
    
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
    
    fileprivate let conn: SQLiteConnection
    
    fileprivate var _bindings: [Binding] = []
    
    public var commandText: String = ""
    
    init(connection: SQLiteConnection) {
        conn = connection
    }
    
    func bind(_ name: String, value: Any) {
        let binding = Binding(name: name, value: value)
        _bindings.append(binding)
    }
    
    func bind(_ value: Any) {
        
    }
    
    func bindAll(_ stmt: Statement) {
        var index = 1
        for var bind in _bindings {
            if let value = bind.value {
                print(value)
            }
            bind.index = SQLite3.bindParameterIndex(stmt, name: bind.name)
        }
    }
    
    static func bindParameter(_ stmt: Statement, index: Int, value: Any?) {
        if let value = value {
            print(value)
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
    
    func prepare() -> Statement? {
        let stmt = SQLite3.prepare(conn.handle, SQL: commandText)
        bindAll(stmt!)
        return stmt
    }
    
//    func executeScalar<T>() -> T {
//
//    }
    
    func executeNonQuery() -> Int {
        guard let stmt = prepare() else {
            return -1
        }
        let r = SQLite3.step(stmt)
        print(r)
        return 0
    }
}
