//
//  TableMapping.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/16.
//

import Foundation

public struct TableMapping {
    
    public class Column {
        
        public let name: String
        
        public let isNullable: Bool
        
        
        
        init() {
            name = ""
            isNullable = false
            
            //let m = Mirror(reflecting: name)
            //Mirror(<#T##subject: Subject##Subject#>, children: <#T##Collection#>, displayStyle: <#T##Mirror.DisplayStyle?#>, ancestorRepresentation: <#T##Mirror.AncestorRepresentation#>)
        }
    }
    
    public var withoutRowId: Bool
    
}
