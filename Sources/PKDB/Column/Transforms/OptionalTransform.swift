//
//  OptionalTransform.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation
import GRDB

extension Optional: ColumnTransformable where Wrapped: ColumnTransformable {
    public static var columnType: ColumnType {
        return Wrapped.columnType
    }
    
    public static func transformFromColumnValue(_ value: Any, from db: Database) -> Optional<Wrapped>? {
        return Wrapped.transformFromColumnValue(value, from: db)
    }
    
    public func transformToColumnValue() -> Any? {
        switch self {
        case let .some(obj):
            return obj.transformToColumnValue()
        default:
            return nil
        }
    }
    
}
