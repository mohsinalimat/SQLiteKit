//
//  PreparedSqliteInsertCommand.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/18.
//

import Foundation

class PreparedSqliteInsertCommand {
    
    private let conn: SQLiteConnection
    
    private let commandText: String
    
    init(connection: SQLiteConnection, commandText: String) {
        self.conn = connection
        self.commandText = commandText
    }
    
    func executeNonQuery(_ args: [Any]) -> Int {
        guard let stmt = SQLite3.prepare(conn.handle, SQL: commandText) else {
            return 0
        }
        for (index, arg) in args.enumerated() {
            SQLiteCommand.bindParameter(stmt, index: index + 1, value: arg)
        }
        let r = SQLite3.step(stmt)
        if r == SQLite3.Result.done {
            let rows = SQLite3.changes(conn.handle)
            return rows
        }
        return 0
    }
    
}
