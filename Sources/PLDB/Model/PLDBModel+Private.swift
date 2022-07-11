//
//  PLDBModel.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation



extension PLDBModel {
    
    /// 获取model中的数据库字段
    /// - Returns:
    func extractColumnDefines() -> [ColumnDefine] {
        
        var defines = [ColumnDefine]()
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if var name = child.label,
               let property = child.value as? ColumnProperty {
                
                let define = property.define
                if define.name == nil {
                    name.removeFirst()
                    define.name = name
                }
                
                defines.append(define)
            }
        }
        return defines
    }
    
    
    func update(_ dict: [AnyHashable: Any]?, from db: PLDB) {
        guard let dict = dict else {
            return
        }
        
        let defines = self.extractColumnDefines()
        
        for define in defines {
            guard let name = define.name else {
                continue
            }
            
            if let value = dict[name], let propertyValue = define.propertyType.transformFromColumnValue(value, from: db) {
                define.setPropertyValue?(propertyValue)
            }
        }
    }
}
