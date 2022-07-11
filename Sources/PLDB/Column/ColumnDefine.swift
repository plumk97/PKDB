//
//  ColumnDefine.swift
//  
//
//  Created by litiezhu on 2022/7/11.
//

import Foundation


class ColumnDefine {
    
    var primaryKey: Bool = false
    var unique: Bool = false
    var notNull: Bool = false
    var autoIncrement: Bool = false
    
    var index: Bool = false
    var uniqueIndex: Bool = false
    
    var defaultValue: Any?
    
    var name: String?
    var columnType: ColumnType = .INTEGER
    
    
    var getPropertyValue: (() -> Any?)?
    var setPropertyValue: ((Any?) -> Void)?
}
