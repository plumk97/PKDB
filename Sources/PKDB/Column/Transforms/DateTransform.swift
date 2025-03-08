//
//  DateTransform.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation
import GRDB

extension Date: ColumnTransformable {
    public static var columnType: ColumnType { .TEXT }
    
    public static func transformFromColumnValue(_ value: Any, from db: Database) -> Self? {
        if let timestamp = value as? TimeInterval {
            return Date(timeIntervalSince1970: timestamp)
        }
        
        if let iso8601 = value as? String {
            return ISO8601DateFormatter().date(from: iso8601)
        }
        return nil
    }
    
    public func transformToColumnValue() -> Any? {
        return ISO8601DateFormatter().string(from: self)
    }
}
