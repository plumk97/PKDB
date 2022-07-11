//
//  DateTransform.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation

extension Date: ColumnTransformable {
    public static var columnType: ColumnType { .REAL }
    
    public static func transformFromColumnValue(_ value: Any, from db: PLDB) -> Self? {
        guard let timestamp = value as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
    
    public func transformToColumnValue() -> Any? {
        return self.timeIntervalSince1970
    }
}
