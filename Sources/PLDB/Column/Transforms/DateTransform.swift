//
//  DateTransform.swift
//  
//
//  Created by litiezhu on 2022/7/11.
//

import Foundation

extension Date: ColumnTransformable {
    static var columnType: ColumnType { .REAL }
    
    static func transformFromColumnValue(_ value: Any) -> Date? {
        guard let timestamp = value as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
    
    func transformToColumnValue() -> Any? {
        return self.timeIntervalSince1970
    }
}
