//
//  StringTransform.swift
//  
//
//  Created by litiezhu on 2022/7/11.
//

import Foundation

extension String: ColumnTransformable {
    static var columnType: ColumnType { .TEXT }
    
    static func transformFromColumnValue(_ value: Any) -> Self? {
        return value as? Self
    }
    
    func transformToColumnValue() -> Any? {
        return self
    }
}
