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
        static func create(_ tableName: String, defines: [ColumnDefine]) -> [String] {
            
            
            var primaryFields = [ColumnDefine]()
            
            var indexFields = [ColumnDefine]()
            var uniqueIndexFields = [ColumnDefine]()
            
            var rows = [String]()
            for define in defines {
                
                let columnType = define.columnType
                guard let name = define.name else {
                    continue
                }
                
                var row = "\"\(name)\" \(columnType.rawValue)"
                
                if define.notNull {
                    row += " NOT NULL"
                }
                
                if let defaultValue = define.defaultValue {
                    row += " DEFAULT \(defaultValue)"
                }
                
                if define.unique {
                    row += " UNIQUE"
                }
                
                if define.primaryKey {
                    primaryFields.append(define)
                }
                
                if define.uniqueIndex {
                    uniqueIndexFields.append(define)
                } else if define.index {
                    indexFields.append(define)
                }
                
                rows.append(row)
            }
            
            var primaryStatment = ""
            if primaryFields.count > 0 {
                primaryStatment = "PRIMARY KEY("
                
                if let define = primaryFields.first(where: { $0.autoIncrement }) {
                    primaryStatment += "\"\(define.name!)\" AUTOINCREMENT"
                } else {
                    primaryStatment += "\(primaryFields.map({ "\"\($0.name!)\"" }).joined(separator: ","))"
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
                \(indexFields.map({ "\"\($0.name!)\" ASC"}).joined(separator: ",\n"))
                );
                """
                
                statments.append(statment)
            }
            
            
            if uniqueIndexFields.count > 0 {
                
                let statment = """
                CREATE UNIQUE INDEX "\(tableName)_Unique_Index" ON "\(tableName)" (
                \(uniqueIndexFields.map({ "\"\($0.name!)\" ASC"}).joined(separator: ",\n"))
                );
                """
                
                statments.append(statment)
            }
            
            return statments
        }
        
        
        /// 生成插入语句
        /// - Parameter model:
        static func insert(_ model: PLDBModel) -> (String, [Any?]) {
            
            let defines = model.extractColumnDefines().filter({ !$0.autoIncrement })
            let fields = defines.map({ "\"\($0.name!)\"" })
            
            let statment = """
            INSERT INTO "\(type(of: model).tableName)" (\(fields.joined(separator: ","))) VALUES (\(fields.map({ _ in "?" }).joined(separator: ",")))
            """
            
            return (statment, generateValues(defines))
        }
        
        
        /// 生成更新语句
        /// - Parameter model:
        /// - Returns:
        static func update(_ model: PLDBModel) -> (String, [Any?]) {
            
            let defines = model.extractColumnDefines().filter({ !$0.autoIncrement })
            let fields = defines.map({ "\"\($0.name!)\"" })
            
            let statment = """
            UPDATE "\(type(of: model).tableName)" SET \(fields.map({ "\($0) = ?"}).joined(separator: ", ")) WHERE \(model.uniqueId.0) = \(model.uniqueId.1)
            """
            
            return (statment, generateValues(defines))
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
        private static func generateValues(_ defines: [ColumnDefine]) -> [Any?] {
            return defines.map({
                let value = $0.getPropertyValue?()
                return value
            })
        }
    }
}
