//
//  SQLiteOpenFlags.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/14.
//

import Foundation

public struct SQLiteOpenFlags: OptionSet {
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    public static let readOnly = SQLiteOpenFlags(rawValue: 1)
    public static let readWrite = SQLiteOpenFlags(rawValue: 2)
    public static let create = SQLiteOpenFlags(rawValue: 4)
    public static let noMutex = SQLiteOpenFlags(rawValue: 0x8000)
    public static let FullMutex = SQLiteOpenFlags(rawValue: 0x10000)
    public static let SharedCache = SQLiteOpenFlags(rawValue: 0x20000)
    public static let PrivateCache = SQLiteOpenFlags(rawValue: 0x40000)
    public static let ProtectionComplete = SQLiteOpenFlags(rawValue: 0x00100000)
    public static let ProtectionCompleteUnlessOpen = SQLiteOpenFlags(rawValue: 0x00200000)
    public static let ProtectionCompleteUntilFirstUserAuthentication = SQLiteOpenFlags(rawValue: 0x00300000)
    public static let ProtectionNone = SQLiteOpenFlags(rawValue: 0x00400000)
}
