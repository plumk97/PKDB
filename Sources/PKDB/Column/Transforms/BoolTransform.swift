//
//  BoolTransform.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation


extension Bool: ColumnTransformable {
    public static var columnType: ColumnType { .BOOLEAN }
    
    public static func transformFromColumnValue(_ value: Any, from db: PKDB) -> Self? {
        return value as? Self
    }
    
    public func transformToColumnValue() -> Any? {
        return self
    }
}
