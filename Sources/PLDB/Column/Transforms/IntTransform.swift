//
//  IntTransform.swift
//  
//
//  Created by litiezhu on 2022/7/11.
//

import Foundation


protocol IntTransform: ColumnTransformable {
}

extension IntTransform {
    static var columnType: ColumnType { .INTEGER }
    
    static func transformFromColumnValue(_ value: Any) -> Self? {
        return value as? Self
    }
    
    func transformToColumnValue() -> Any? {
        return self
    }
}


extension Int: IntTransform {}
extension UInt: IntTransform {}
extension Int8: IntTransform {}
extension Int16: IntTransform {}
extension Int32: IntTransform {}
extension Int64: IntTransform {}
extension UInt8: IntTransform {}
extension UInt16: IntTransform {}
extension UInt32: IntTransform {}
extension UInt64: IntTransform {}
