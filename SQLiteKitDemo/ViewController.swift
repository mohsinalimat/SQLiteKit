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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


struct User: SQLiteTable {
    
    var name: String
    
    var age: Int
    
    var birthday: Date
    
    func attributes() -> [ColumnAttribute] {
        return [
            ColumnAttribute(name: "name", info: .autoInc)
        ]
    }
}
