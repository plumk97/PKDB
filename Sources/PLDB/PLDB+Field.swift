//
//  PLDB+Field.swift
//  PLDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation

protocol PLDBFieldWrapper {
    var fieldDescription: PLDB.FieldDescription { get }
}

extension PLDB {

    class FieldDescription {
        
        var primaryKey: Bool = false
        var unique: Bool = false
        var notNull: Bool = false
        var autoIncrement: Bool = false
        
        var index: Bool = false
        var uniqueIndex: Bool = false
        
        var defaultValue: Any?
        
        var fieldName: String?
        var fieldType: PLDBFieldType.Type!
        
        
        var getValue: (() -> Any)!
        var setValue: ((Any) -> Void)!
    }
    
    
    @propertyWrapper public class Field<Value: PLDBFieldType>: PLDBFieldWrapper, CustomStringConvertible {
        
        private let _fieldDescription = FieldDescription()
        
        
        public init(wrappedValue value: Value,
             defaultValue: Value? = nil,
             primaryKey: Bool = false,
             unique: Bool = false,
             notNull: Bool = false,
             autoIncrement: Bool = false,
             index: Bool = false,
             uniqueIndex: Bool = false) {
            
            self.value = value
            
            _fieldDescription.defaultValue = defaultValue
            _fieldDescription.primaryKey = primaryKey
            _fieldDescription.unique = unique
            _fieldDescription.notNull = notNull
            _fieldDescription.autoIncrement = autoIncrement
            _fieldDescription.index = index
            _fieldDescription.uniqueIndex = uniqueIndex

            _fieldDescription.fieldType = Value.self
            
            _fieldDescription.getValue = {[unowned self] in
                return self.value
            }
            
            _fieldDescription.setValue = {[unowned self] in
                self.setCurrentValue($0)
            }
        }
        
        private var value: Value
        public var wrappedValue: Value {
            get { return value }
            set { value = newValue }
        }

        
        // MARK: - CustomStringConvertible
        public var description: String {
            var output = ""
            print(self.value, separator: "", terminator: "", to: &output)
            return output
        }
        
        
        // MARK: - PLDBFieldProperty
        var fieldDescription: PLDB.FieldDescription { self._fieldDescription }
        
        private func setCurrentValue(_ value: Any) {
            
            
            switch Value.self {
                
            case is Date.Type:
                if let x = value as? TimeInterval {
                    self.value = Date(timeIntervalSince1970: x) as! Value
                }
                
            default:
                if let nv = value as? Value {
                    self.value = nv
                }
            }
        }
    }
}
