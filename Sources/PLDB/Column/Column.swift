//
//  Column.swift
//  
//
//  Created by litiezhu on 2022/7/11.
//

import Foundation


protocol ColumnProperty {
 
    var define: ColumnDefine { get }
}

@propertyWrapper public class Column<Value>: CustomStringConvertible, ColumnProperty {
    
    let define: ColumnDefine = ColumnDefine()
    var value: Value
    
    
    public var wrappedValue: Value {
        get { return value }
        set { value = newValue }
    }
    
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
        
        print(Value.self is PLDBModel.Type)
        
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
