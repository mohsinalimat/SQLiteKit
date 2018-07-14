//
//  SQLite3.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation
import SQLite3

typealias Statement = OpaquePointer

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
    
    static func open(filename: String, flags: SQLiteOpenFlags) {
//        let result = sqlite3_open_v2(<#T##filename: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>, <#T##ppDb: UnsafeMutablePointer<OpaquePointer?>!##UnsafeMutablePointer<OpaquePointer?>!#>, <#T##flags: Int32##Int32#>, <#T##zVfs: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>)
    }
    
    static func prepare(dbHandle: OpaquePointer, SQL: String) -> Statement? {
        var stmt: Statement? = nil
        let result = sqlite3_prepare_v2(dbHandle, SQL, -1, &stmt, nil)
        return stmt
    }
    
    static func step(stmt: Statement) -> Result? {
        let result = sqlite3_step(stmt)
        return Result(rawValue: result)
    }
    
    static func reset(stmt: Statement) -> Result? {
        let result = sqlite3_reset(stmt)
        return Result(rawValue: result)
    }
    
    // MARK: - Bind Begin
    
    static func bindInt(stmt: Statement, index: Int, value: Int) -> Int32 {
        return sqlite3_bind_int(stmt, Int32(index), Int32(value))
    }
    
    static func bindInt64(stmt: Statement, index: Int, value: Int64) -> Int {
        return Int(sqlite3_bind_int64(stmt, Int32(index), value))
    }
    
    static func bindText(stmt: Statement, index: Int, value: String) -> Int {
        return Int(sqlite3_bind_text(stmt, Int32(index), value, -1, SQLITE_TRANSIENT))
    }
    
    static func bindBlob(stmt: Statement, index: Int, value: Data) -> Int {
//        value.copyBytes(to: <#T##UnsafeMutableBufferPointer<DestinationType>#>)
//        return Int(sqlite3_bind_blob(stmt, Int32(index), value.bytes, <#T##n: Int32##Int32#>, <#T##((UnsafeMutableRawPointer?) -> Void)!##((UnsafeMutableRawPointer?) -> Void)!##(UnsafeMutableRawPointer?) -> Void#>))
        return 0
    }
    
    // MARK: - Column
    
    static func columnCount(stmt: Statement) -> Int {
        return Int(sqlite3_column_count(stmt))
    }
    
    static func columnName(stmt: Statement, index: Int) -> String {
        let str = sqlite3_column_name(stmt, Int32(index))!
        return String(cString: str)
    }
    
    static func columnType(stmt: Statement, index: Int) -> ColumnType {
        let type = sqlite3_column_type(stmt, Int32(index))
        return ColumnType(rawValue: type)!
    }
}
