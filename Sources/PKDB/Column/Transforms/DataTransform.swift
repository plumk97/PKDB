//
//  DataTransform.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation
import GRDB

extension Data: ColumnTransformable {
    public static var columnType: ColumnType { .BLOB }
    
    public static func transformFromColumnValue(_ value: Any, from db: Database) -> Self? {
        return value as? Self
    }
    
    public func transformToColumnValue() -> Any? {
        return self
    }
}
