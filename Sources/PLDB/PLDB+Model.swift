//
//  PLDB+Model.swift
//  PLDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation


/// 数据表模型
public protocol PLDBModel: PLDBFieldType {
    init()
    
    /// 唯一Id 用于更新删除 返回字段名 字段值
    var uniqueId: (String, Int) { get }
    
    /// 表名
    static var tableName: String { get }
}

extension PLDBModel {
    
    /// 获取model中的数据库字段
    /// - Returns:
    func extractFields() -> [PLDB.FieldDescription] {
        
        var descriptions = [PLDB.FieldDescription]()
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if var name = child.label,
               let property = child.value as? PLDBFieldWrapper {
                name.removeFirst()
                
                let desc = property.fieldDescription
                desc.fieldName = name
                descriptions.append(desc)
            }
        }
        return descriptions
    }
    
    
    func update(_ dict: [AnyHashable: Any]?) {
        guard let dict = dict else {
            return
        }
        
        let fds = self.extractFields()
        
        for fd in fds {
            guard let fieldName = fd.fieldName else {
                continue
            }
            
            if let value = dict[fieldName] {
                fd.setValue(value)
            }

        }
    }
}
