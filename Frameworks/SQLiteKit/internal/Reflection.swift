//
//  Reflection.swift
//  SQLiteKit
//
//  Created by xu.shuifeng on 2018/7/20.
//

import Foundation

struct ClassMetadata {
    var type: Any.Type
}

struct ProtocolTypeContainer {
    let type: Any.Type
    let witnessTable: Int
}

protocol AnyReflectable { }

extension AnyReflectable {
    static func get(from pointer: UnsafeRawPointer) -> Any {
        return pointer.assumingMemoryBound(to: self).pointee
    }
    
    static func set(value: Any, pointer: UnsafeMutableRawPointer) {
        if let value = value as? Self {
            pointer.assumingMemoryBound(to: self).initialize(to: value)
        }
    }
}

func reflectable(of type: Any.Type) -> AnyReflectable.Type {
    let container = ProtocolTypeContainer(type: type, witnessTable: 0)
    return unsafeBitCast(container, to: AnyReflectable.Type.self)
}

func withClassValuePointer<Value, Result>(of value: inout Value, _ body: (UnsafeMutableRawPointer) -> Result) -> Result {
    return withUnsafePointer(to: &value) {
        let pointer = $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) { $0.pointee }
        return body(pointer)
    }
}

class Reflection {
    
    class func set<T: SQLiteTable>(_ value: Any, key: String, for instance: inout T) {
        withClassValuePointer(of: &instance) { pointer in
            let valuePointer = pointer.advanced(by: 1) // TODO
            let sets = reflectable(of: T.self)
            sets.set(value: value, pointer: valuePointer)
        }
        
    }
    
}
