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
    
    @discardableResult
    func executeNonQuery() -> Int {
        guard let stmt = prepare() else {
            return 0
        }
        guard let r = SQLite3.step(stmt) else {
            return 0
        }
        
        if r == SQLite3.Result.done {
            let rowsAffected = SQLite3.changes(conn.handle)
            return rowsAffected
        } else if r == SQLite3.Result.error {
            let msg = SQLite3.getErrorMessage(conn.handle)
            let error = SQLiteError.excuteError(Int(r.rawValue), msg)
            print(error)
        }
    
        return 0
    }
    
    func executeQuery<T: SQLiteTable>() -> [T] {
        let map = conn.getMapping(of: T.self)
        return executeDeferredQuery(map)
    }
    
    func executeDeferredQuery<T: SQLiteTable>(_ map: TableMapping) -> [T] {
        
        guard let stmt = prepare() else {
            return []
        }
        
        let columnCount = SQLite3.columnCount(stmt)
        var cols: [TableMapping.Column] = []
        for i in 0..<columnCount {
            let name = SQLite3.columnName(stmt, index: i)
            if let column = map.findColumn(with: name) {
                cols.append(column)
            }
        }
        
        var result: [T] = []
        while SQLite3.step(stmt) == SQLite3.Result.row {
            // currently use JSONSerialization and JSONDecoder to ORM mapping
            var dict: [String: Any?] = [:]
            // read cols
            for i in 0..<columnCount {
                let colType = SQLite3.columnType(stmt, index: i)
                let value = readColumn(stmt, index: i, columnType: colType)
                dict[cols[i].name] = value
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                let obj = try JSONDecoder().decode(T.self, from: data)
                result.append(obj)
            } catch {
                print(error)
            }
        }
        return result
    }
}
