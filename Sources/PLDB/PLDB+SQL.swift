//
//  PLDB+SQL.swift
//  PLDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation


extension PLDB {
    class SQL {
        
        
        /// 生成创建表语句
        /// - Parameters:
        ///   - tableName:
        ///   - descriptions:
        static func create(_ tableName: String, descriptions: [FieldDescription]) -> [String] {
            
            
            var primaryFields = [FieldDescription]()
            
            var indexFields = [FieldDescription]()
            var uniqueIndexFields = [FieldDescription]()
            
            var rows = [String]()
            for desc in descriptions {
                
                let sqlType = desc.fieldType.sqliteType
                guard let fieldName = desc.fieldName else {
                    continue
                }
                
                var row = "\"\(fieldName)\" \(sqlType)"
                
                if desc.notNull {
                    row += " NOT NULL"
                }
                
                if let defaultValue = desc.defaultValue {
                    row += " DEFAULT \(defaultValue)"
                }
                
                if desc.unique {
                    row += " UNIQUE"
                }
                
                if desc.primaryKey {
                    primaryFields.append(desc)
                }
                
                if desc.uniqueIndex {
                    uniqueIndexFields.append(desc)
                } else if desc.index {
                    indexFields.append(desc)
                }
                
                rows.append(row)
            }
            
            var primaryStatment = ""
            if primaryFields.count > 0 {
                primaryStatment = "PRIMARY KEY("
                
                if let desc = primaryFields.first(where: { $0.autoIncrement }) {
                    primaryStatment += "\"\(desc.fieldName!)\" AUTOINCREMENT"
                } else {
                    primaryStatment += "\(primaryFields.map({ "\"\($0.fieldName!)\"" }).joined(separator: ","))"
                }
                primaryStatment += ")"
            }
            
            
            var createStatement = "CREATE TABLE \"\(tableName)\" (\n"
            createStatement += rows.joined(separator: ",\n")
            if primaryStatment.count > 0 {
                createStatement += ",\n"
                createStatement += primaryStatment + "\n"
            } else {
                createStatement += "\n"
            }
            createStatement += ");"
            
            var statments = [createStatement]
            
            if indexFields.count > 0 {
                
                let statment = """
                CREATE INDEX "\(tableName)_Index" ON "\(tableName)" (
                \(indexFields.map({ "\"\($0.fieldName!)\" ASC"}).joined(separator: ",\n"))
                );
                """
                
                statments.append(statment)
            }
            
            
            if uniqueIndexFields.count > 0 {
                
                let statment = """
                CREATE UNIQUE INDEX "\(tableName)_Unique_Index" ON "\(tableName)" (
                \(uniqueIndexFields.map({ "\"\($0.fieldName!)\" ASC"}).joined(separator: ",\n"))
                );
                """
                
                statments.append(statment)
            }
            
            return statments
        }
        
        
        /// 生成插入语句
        /// - Parameter model:
        static func insert(_ model: PLDBModel) -> (String, [Any?]) {
            
            let descriptions = model.extractFields().filter({ !$0.autoIncrement })
            let fields = descriptions.map({ "\"\($0.fieldName!)\"" })
            
            let statment = """
            INSERT INTO "\(type(of: model).tableName)" (\(fields.joined(separator: ","))) VALUES (\(fields.map({ _ in "?" }).joined(separator: ",")))
            """
            
            return (statment, generateValues(descriptions))
        }
        
        
        /// 生成更新语句
        /// - Parameter model:
        /// - Returns:
        static func update(_ model: PLDBModel) -> (String, [Any?]) {
            
            let descriptions = model.extractFields().filter({ !$0.autoIncrement })
            let fields = descriptions.map({ "\"\($0.fieldName!)\"" })
            
            let statment = """
            UPDATE "\(type(of: model).tableName)" SET \(fields.map({ "\($0) = ?"}).joined(separator: ", ")) WHERE \(model.uniqueId.0) = \(model.uniqueId.1)
            """
            
            return (statment, generateValues(descriptions))
        }
        
        
        /// 生成删除语句
        /// - Parameter model:
        /// - Returns:
        static func delete(_ model: PLDBModel) -> String {
            
            let statment = """
            DELETE FROM "\(type(of: model).tableName)" WHERE \(model.uniqueId.0) = \(model.uniqueId.1)
            """
            return statment
        }
        
        
        /// 生成删除表所有数据语句
        /// - Parameter model:
        /// - Returns:
        static func deleteTable(_ cls: PLDBModel.Type) -> String {
            let statment = """
            DELETE FROM "\(cls.tableName)"
            """
            return statment
        }
        
        /// 生成Values
        /// - Parameter descriptions:
        /// - Returns:
        private static func generateValues(_ descriptions: [PLDB.FieldDescription]) -> [Any] {
            return descriptions.map({
                let value = $0.getValue()
                
                if let model = value as? PLDBModel {
                    return model.uniqueId.1
                }
                
                if let date = value as? Date {
                    return date.timeIntervalSince1970
                }
                
                return value
            })
        }
    }
}
