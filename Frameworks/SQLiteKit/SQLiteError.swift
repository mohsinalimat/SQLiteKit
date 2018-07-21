//
//  SQLiteError.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/17.
//

import Foundation

/// SQLite Errors that maybe throwed by SQLiteKit
///
/// - openDataBaseError: Can not open the database file to operate. With Error Message and error
/// - executeError: Execute statement occurs exception
public enum SQLiteError: Error {
    case openDataBaseError(String)
    case executeError(Int, String)
}
