//
//  PKDBModel.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation
import GRDB

extension PKDBModel {
    
    /// 获取model中的数据库字段
    /// - Returns:
    func extractColumnDefines() -> [ColumnDefine] {
        
        var defines = [ColumnDefine]()
        
        func extract(_ mirror: Mirror) {
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
            
            if let superMirror = mirror.superclassMirror {
                extract(superMirror)
            }
        }
        
        let mirror = Mirror(reflecting: self)
        extract(mirror)
        
        return defines
    }
    
    
    func update(_ dict: [AnyHashable: Any]?, from db: Database) {
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
