//
//  SQLiteRow.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/5/24.
//

import Foundation

public typealias SQLiteRowList = [SQLiteRow]

public class SQLiteRow {
    
    let dataDict: [AnyHashable: Any]
    
    public init(dictionary: [AnyHashable: Any]) {
        self.dataDict = dictionary
    }
    
//    public subscrip(column: SQLiteColumn) -> String? {
//
//    }
}
