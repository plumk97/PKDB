//
//  FloatTransform.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation

public protocol FloatTransform: ColumnTransformable {
}

public extension FloatTransform {
    static var columnType: ColumnType { .REAL }
    
    static func transformFromColumnValue(_ value: Any, from db: PKDB) -> Self? {
        return value as? Self
    }
    
    func transformToColumnValue() -> Any? {
        return self
    }
}


extension Float: FloatTransform {}
extension Double: FloatTransform {}
