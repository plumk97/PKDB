//
//  PLDBModel+Model.swift
//  PLDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation


/// 数据表模型
public protocol PLDBModel: ColumnTransformable {
    init()
    
    /// 表名
    static var tableName: String { get }
    
    /// 唯一id 字段名
    static var uniqueIdName: String { get }
    
    /// 唯一id 值
    var uniqueId: Int { get }
}


public extension PLDBModel {
    /// 字段类型
    static var columnType: ColumnType {
        return .INTEGER
    }
    
    /// 转换数据库数据为当前类型
    /// - Parameter value:
    /// - Returns:
    static func transformFromColumnValue(_ value: Any, from db: PLDB) -> Self? {
        guard let uniqueId = value as? Int else {
            return nil
        }
        
        return db.query(self).where("id = ?", uniqueId).first()
    }
    
    /// 转换当前数据为数据库数据
    /// - Returns:
    func transformToColumnValue() -> Any? {
        return self.uniqueId
    }
}
