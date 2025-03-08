//
//  FloatTransform.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation
import GRDB

public protocol FloatTransform: ColumnTransformable, BinaryFloatingPoint {
}

public extension FloatTransform {
    static var columnType: ColumnType { .REAL }
    
    static func transformFromColumnValue(_ value: Any, from db: Database) -> Self? {
        if let floatValue = value as? any BinaryFloatingPoint {
            return self.init(floatValue)
        }
        
        return 0
    }
    
    func transformToColumnValue() -> Any? {
        return self
    }
}


extension Float: FloatTransform {}
extension Double: FloatTransform {}
