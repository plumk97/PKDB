//
//  Column.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation



/// 属性封装器包裹协议
protocol ColumnProperty {
    
    /// 字段定义
    var define: ColumnDefine { get }
}

@propertyWrapper public class Column<Value: ColumnTransformable>: CustomStringConvertible, ColumnProperty {
    
    /// 字段定义
    let define: ColumnDefine = ColumnDefine()
    
    /// 当前包裹的值
    var value: Value
    
    ///
    public var wrappedValue: Value {
        get { return value }
        set { value = newValue }
    }
    
    /// 初始化
    /// - Parameters:
    ///   - value: 初始值
    ///   - defaultValue: 字段-默认值
    ///   - primaryKey: 字段-是否主键
    ///   - unique: 字段-是否唯一
    ///   - notNull: 字段-是否不能为空
    ///   - autoIncrement: 字段-是否自增
    ///   - index: 字字段-是否添加索引
    ///   - uniqueIndex: 字段-是否添加唯一索引
    ///   - name: 字段-字段名 不设置取属性名
    public init(wrappedValue value: Value,
                defaultValue: Value? = nil,
                primaryKey: Bool = false,
                unique: Bool = false,
                notNull: Bool = false,
                autoIncrement: Bool = false,
                index: Bool = false,
                uniqueIndex: Bool = false,
                name: String? = nil) {
        
        self.value = value
        
        self.define.defaultValue = defaultValue
        
        self.define.primaryKey = primaryKey
        self.define.unique = unique
        self.define.notNull = notNull
        self.define.autoIncrement = autoIncrement
        self.define.index = index
        self.define.uniqueIndex = uniqueIndex
        self.define.name = name
        self.define.columnType = Value.columnType
        
        self.define.propertyType = Value.self
        
        self.define.getPropertyValue = getPropertyValue
        self.define.setPropertyValue = setPropertyValue(_:)
    }
    
    func getPropertyValue() -> Any {
        return self.value
    }
    
    func setPropertyValue(_ value: Any?) {
        if let x = value as? Value {
            self.value = x
        }
    }
    
    // MARK: - CustomStringConvertible
    public var description: String {
        var output = ""
        print(self.value, separator: "", terminator: "", to: &output)
        return output
    }
}
