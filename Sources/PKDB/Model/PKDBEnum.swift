//
//  PKDBEnum.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation

public protocol PKDBEnum: ColumnTransformable {
    
}

public extension RawRepresentable where Self: PKDBEnum, RawValue: ColumnTransformable {
    
    /// 字段类型
    static var columnType: ColumnType { RawValue.columnType }
    
    /// 转换数据库数据为当前类型
    /// - Parameter value:
    /// - Returns:
    static func transformFromColumnValue(_ value: Any, from db: PKDB) -> Self? {
        if let x = RawValue.transformFromColumnValue(value, from: db) {
            return .init(rawValue: x)
        }
        return nil
    }
    
    /// 转换当前数据为数据库数据
    /// - Returns:
    func transformToColumnValue() -> Any? {
        return self.rawValue.transformToColumnValue()
    }
}
