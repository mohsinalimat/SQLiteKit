//
//  SQLite3.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation
import SQLite3

typealias Statement = OpaquePointer

typealias DatabaseHandle = OpaquePointer

let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

class SQLite3 {
    
    enum Result: Int32 {
        case ok = 0
        case error = 1
        case `internal` = 2
        case perm = 3
        case abort = 4
        case busy = 5
        case locked = 6
        case noMemory = 7
        case readOnly = 8
        case interrupt = 9
        case iOError = 10
        case corrupt = 11
        case notFound = 12
        case full = 13
        case cannotOpen = 14
        case lockErr = 15
        case empty = 16
        case schemaChngd = 17
        case tooBig = 18
        case constraint = 19
        case mismatch = 20
        case misuse = 21
        case notImplementedLFS = 22
        case accessDenied = 23
        case format = 24
        case range = 25
        case nonDBFile = 26
        case notice = 27
        case warning = 28
        case row = 100
        case done = 101
    }
    
    enum ColumnType: Int32 {
        case Integer = 1
        case Float = 2
        case Text = 3
        case Blob = 4
        case Null = 5
    }
    
    static func open(filename: String, db: inout DatabaseHandle?, flags: SQLiteOpenFlags) -> Result? {
        let result = sqlite3_open_v2(filename, &db, flags.rawValue, nil)
        return Result(rawValue: result)
    }
    
    static func close(_ handle: DatabaseHandle) -> Result? {
        let result = sqlite3_close_v2(handle)
        return Result(rawValue: result)
    }
    
    static func changes(_ db: DatabaseHandle) -> Int {
        return Int(sqlite3_changes(db))
    }
    
    static func prepare(_ db: OpaquePointer, SQL: String) -> Statement? {
        var stmt: Statement? = nil
        let _ = sqlite3_prepare_v2(db, SQL, -1, &stmt, nil)
        return stmt
    }
    
    static func step(_ stmt: Statement) -> Result? {
        let result = sqlite3_step(stmt)
        return Result(rawValue: result)
    }
    
    static func reset(_ stmt: Statement) -> Result? {
        let result = sqlite3_reset(stmt)
        return Result(rawValue: result)
    }
    
    static func lastInsertRowid(_ db: DatabaseHandle) -> Int64 {
        return sqlite3_last_insert_rowid(db)
    }
    
    static func getErrorMessage(_ db: DatabaseHandle) -> String {
        return String(cString: sqlite3_errmsg(db))
    }
    
    // MARK: - Bind Begin
    @discardableResult
    static func bindParameterIndex(_ stmt: Statement, name: String) -> Int {
        let result = sqlite3_bind_parameter_index(stmt, name)
        return Int(result)
    }
    
    @discardableResult
    static func bindNull(_ stmt: Statement, index: Int) -> Int {
        return Int(sqlite3_bind_null(stmt, Int32(index)))
    }
    
    @discardableResult
    static func bindInt(_ stmt: Statement, index: Int, value: Int) -> Int {
        return Int(sqlite3_bind_int(stmt, Int32(index), Int32(value)))
    }
    
    @discardableResult
    static func bindInt64(_ stmt: Statement, index: Int, value: Int64) -> Int {
        return Int(sqlite3_bind_int64(stmt, Int32(index), value))
    }
    
    @discardableResult
    static func bindDouble(_ stmt: Statement, index: Int, value: Double) -> Int {
        return Int(sqlite3_bind_double(stmt, Int32(index), value))
    }
    
    @discardableResult
    static func bindText(_ stmt: Statement, index: Int, value: String) -> Int {
        return Int(sqlite3_bind_text(stmt, Int32(index), value, -1, SQLITE_TRANSIENT))
    }
    
    @discardableResult
    static func bindBlob(_ stmt: Statement, index: Int, value: Data) -> Int {
//        value.copyBytes(to: <#T##UnsafeMutableBufferPointer<DestinationType>#>)
//        return Int(sqlite3_bind_blob(stmt, Int32(index), value.bytes, <#T##n: Int32##Int32#>, <#T##((UnsafeMutableRawPointer?) -> Void)!##((UnsafeMutableRawPointer?) -> Void)!##(UnsafeMutableRawPointer?) -> Void#>))
        return 0
    }
    
    // MARK: - Column
    
    static func columnCount(_ stmt: Statement) -> Int {
        return Int(sqlite3_column_count(stmt))
    }
    
    static func columnName(_ stmt: Statement, index: Int) -> String {
        let str = sqlite3_column_name(stmt, Int32(index))!
        return String(cString: str)
    }
    
    static func columnType(_ stmt: Statement, index: Int) -> ColumnType {
        let type = sqlite3_column_type(stmt, Int32(index))
        return ColumnType(rawValue: type)!
    }
    
    static func columnInt(_ stmt: Statement, index: Int) -> Int {
        return Int(sqlite3_column_int(stmt, Int32(index)))
    }
    
    static func columnInt64(_ stmt: Statement, index: Int) -> Int64 {
        return Int64(sqlite3_column_int64(stmt, Int32(index)))
    }
    
    static func columnDouble(_ stmt: Statement, index: Int) -> Double {
        return Double(sqlite3_column_double(stmt, Int32(index)))
    }
}
