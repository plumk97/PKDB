//
//  BoolTransform.swift
//  
//
//  Created by litiezhu on 2022/7/11.
//

import Foundation


extension Bool: ColumnTransformable {
    static var columnType: ColumnType { .BOOLEAN }
    
    static func transformFromColumnValue(_ value: Any) -> Self? {
        return value as? Self
    }
    
    func transformToColumnValue() -> Any? {
        return self
    }
}
