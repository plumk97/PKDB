//
//  OptionalTransform.swift
//  
//
//  Created by litiezhu on 2022/7/11.
//

import Foundation

extension Optional: ColumnTransformable {
    static var columnType: ColumnType {
        return .INTEGER
    }
    
    static func transformFromColumnValue(_ value: Any) -> Optional<Wrapped>? {
        return nil
    }
    
    func transformToColumnValue() -> Any? {
        return nil
    }
    
}
