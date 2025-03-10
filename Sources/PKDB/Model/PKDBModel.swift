//
//  PKDBModel+Model.swift
//  PKDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation
import GRDB

/// 数据表模型
public protocol PKDBModel: ColumnTransformable {
    init()
    
    /// 表名
    static var tableName: String { get }
    
    /// 唯一id 字段名
    static var uniqueIdName: String { get }
    
    /// 唯一id 值
    var uniqueId: Int { get }
}


public extension PKDBModel {
    /// 字段类型
    static var columnType: ColumnType {
        return .INTEGER
    }
    
    /// 转换数据库数据为当前类型
    /// - Parameter value:
    /// - Returns:
    static func transformFromColumnValue(_ value: Any, from db: Database) -> Self? {
        guard let intValue = value as? any BinaryInteger else {
            return nil
        }
        let uniqueId = Int.init(truncatingIfNeeded: intValue)
        do {
            return try Query(db).get(uniqueId)
        } catch {
            print(error)
            return nil
        }
    }
    
    /// 转换当前数据为数据库数据
    /// - Returns:
    func transformToColumnValue() -> Any? {
        return self.uniqueId
    }
}
