//
//  ColumnTransformable.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation


public protocol ColumnTransformable {
    
    /// 字段类型
    static var columnType: ColumnType { get }
    
    /// 转换数据库数据为当前类型
    /// - Parameter value:
    /// - Returns:
    static func transformFromColumnValue(_ value: Any, from db: PLDB) -> Self?
    
    /// 转换当前数据为数据库数据
    /// - Returns:
    func transformToColumnValue() -> Any?
}

