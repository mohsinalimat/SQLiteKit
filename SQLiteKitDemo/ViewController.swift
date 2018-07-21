//
//  ViewController.swift
//  SQLiteKitDemo
//
//  Created by xu.shuifeng on 2018/6/1.
//  Copyright © 2018 shuifeng.me. All rights reserved.
//

import UIKit
import SQLiteKit

class ViewController: UIViewController {

    let dbPath = NSHomeDirectory().appending("/Documents/db.sqlite")
    var db: SQLiteConnection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // deleteDatabase()
        
        db = SQLiteConnection(databasePath: dbPath)
        db.createTable(User.self)
        
        //insertUsers()
        
        queryUser()
    }
    
    fileprivate func deleteDatabase() {
        try? FileManager.default.removeItem(atPath: dbPath)
    }
    
    fileprivate func queryUser() {
        let userQuery: SQLiteTableQuery<User> = db.table()
        let count = userQuery.count
        print("find users count:\(count)")
        let users: [User] = db.table().list()
        print(users)
        
        let a: [User] = userQuery.filter(using: NSPredicate(format: "name = %@", "A"))
        if a.count > 0 {
            
        }
    }
    
    fileprivate func insertUsers() {
        let users = [
            ("A", 11),
            ("B", 12),
            ("C", 13),
            ("D", 14)
        ]
        
        users.forEach { item in
            let user = User()
            user.name = item.0
            user.age = item.1
            db.insert(user)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


class User: SQLiteTable, CustomStringConvertible {
    
    var userID: Int
    
    var name: String
    
    var age: Int
    
    var birthday: Date
    
    var avatarData: Data?
    
    static func sqliteAttributes() -> [SQLiteAttribute] {
        return [
            SQLiteAttribute(name: "userID", attribute: .isPK),
            SQLiteAttribute(name: "userID", attribute: .autoInc)
        ]
    }
    
    required init() {
        userID = 0
        name = ""
        age = 0
        birthday = Date()
    }
    
    var description: String {
        return "userID: \(userID), name: \(name), age:\(age), birthday:\(birthday)"
    }
}
