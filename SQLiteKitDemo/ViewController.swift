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
        
        //deleteDatabase()
        
        db = try! SQLiteConnection(databasePath: dbPath)
        
        //try! db.createTable(User.self)
        
//        insertUsers()
        
        queryUser()
    }
    
    fileprivate func deleteDatabase() {
        try? FileManager.default.removeItem(atPath: dbPath)
    }
    
    fileprivate func queryUser() {
        let userQuery: SQLiteTableQuery<User> = db.table()
        let count = userQuery.count
        print("find users count:\(count)")
        var users: [User] = userQuery.limit(3).toList()
        print(users)
        
        let u = User()
        u.userID = 2
        u.name = "222"
        u.age = 30
        u.birthday = Date()
        
        try! db.upsert(u)
        
        users = userQuery.limit(3).toList()
        print(users)
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
            try! db.insert(user)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


class User: SQLiteTable, CustomStringConvertible {
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case name
        case age
        case birthday
        case avatarData = "avatar_data"
    }
    
    var userID: Int
    
    var name: String
    
    var age: Int
    
    var birthday: Date
    
    //var money: CGFloat
    
    var avatarData: Data?
    
    //var school: School
    
    static func attributes() -> [SQLiteAttribute] {
        return [
            SQLiteAttribute(name: "userID", attribute: .isPK),
            SQLiteAttribute(name: "userID", attribute: .autoInc)
        ]
    }
    
    required init() {
        userID = 0
        name = ""
        age = 0
        //money = 0
        birthday = Date()
        //school = School(name: "TTT", rank: 0)
    }
    
    var description: String {
        return "userID: \(userID), name: \(name), age:\(age), birthday:\(birthday)"
    }
}

class School: Codable {
    
    public let name: String
    
    public let rank: Int
    
    init(name: String, rank: Int) {
        self.name = name
        self.rank = rank
    }
}
