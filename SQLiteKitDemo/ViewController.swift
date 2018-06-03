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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let path = NSHomeDirectory().appending("db.sqlite")
        let database = SQLiteDatabase(path: path)
        
        database.createTable(UserModel.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class UserModel: SQLiteModelProtocol {
    
    let name: String
    
    let age: Int
    
    let score: Float
    
    let avatarData: Data
    
    // MARK: - SQLiteModelProtocol
    
    static var tableName: String {
        return "Users"
    }
    
    var values: [Any] {
        return [name, age, score, avatarData]
    }
    
    static var columns: [SQLiteColumn] {
        return [
            SQLiteColumn(name: "name", dataType: .string),
            SQLiteColumn(name: "age", dataType: .int),
            SQLiteColumn(name: "score", dataType: .float),
            SQLiteColumn(name: "avatarData", dataType: .data)
        ]
    }
}
