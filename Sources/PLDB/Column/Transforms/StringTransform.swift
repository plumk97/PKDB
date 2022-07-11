//
//  StringTransform.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation

extension String: ColumnTransformable {
    public static var columnType: ColumnType { .TEXT }
    
    public static func transformFromColumnValue(_ value: Any, from db: PLDB) -> Self? {
        return value as? Self
    }
    
    public func transformToColumnValue() -> Any? {
        return self
    }
}
