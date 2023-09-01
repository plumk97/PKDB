//
//  ColumnDefine.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation


class ColumnDefine {
    
    /// 是否设置为主键
    var primaryKey: Bool = false
    
    /// 是否唯一
    var unique: Bool = false
    
    /// 是否不能为null
    var notNull: Bool = false
    
    /// 是否自增
    var autoIncrement: Bool = false
    
    /// 是否设置索引
    var index: Bool = false
    
    /// 是否设置唯一索引
    var uniqueIndex: Bool = false
    
    /// 默认值
    var defaultValue: Any?
    
    /// 字段名
    var name: String?
    
    /// 字段类型
    var columnType: ColumnType = .INTEGER
    
    // - Property wrapper
    
    /// 属性类型
    var propertyType: ColumnTransformable.Type!
    
    /// 获取当前属性值
    var getPropertyValue: (() -> Any)?
    
    /// 设置属性
    var setPropertyValue: ((Any) -> Void)?
}
