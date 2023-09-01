//
//  PKDB.swift
//  PKDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation
import FMDB

public class PKDB {
    
    private(set) var database: FMDatabase!
    
    public init(path: String) {
        self.database = FMDatabase(path: path)
    }
    
    /// 打开数据库
    /// - Returns:
    @discardableResult
    public func open() -> Bool {
        return self.database.open()
    }
    
    /// 关闭数据库
    /// - Returns:
    @discardableResult
    public func setKey(_ key: String) -> Bool {
        return self.database.setKey(key)
    }
    
    /// 关闭数据库
    /// - Returns:
    @discardableResult
    public func close() -> Bool {
        return self.database.close()
    }
    
    /// 判断表是否存在
    /// - Parameter cls:
    /// - Returns:
    @discardableResult
    public func tableExists(_ cls: PKDBModel.Type) -> Bool {
        return self.database.tableExists(cls.tableName)
    }
    
    /// 创建一张表
    /// - Parameter model:
    /// - Returns:
    @discardableResult
    public func createTable(_ model: PKDBModel) -> Bool {
        if self.tableExists(type(of: model)) {
            return true
        }
        
        let statemts = SQL.create(model)
        return self.database.executeStatements(statemts.joined(separator: "\n"))
    }
    
    /// 创建一条数据
    /// - Parameter model:
    /// - Returns:
    public func create<T: PKDBModel>(_ model: T) -> T {
        return self.recursionCreate(model) as! T
    }
    
    
    /// 递归创建数据 如果有引用外部表也一起创建
    /// - Parameter model:
    /// - Returns:
    private func recursionCreate(_ model: PKDBModel) -> PKDBModel {
        let defines = model.extractColumnDefines()
        for define in defines {
            if let m = define.getPropertyValue?() as? PKDBModel {
                define.setPropertyValue?(self.recursionCreate(m))
            }
        }
        
        let tp = SQL.insert(model)

        let isOk = self.database.executeUpdate(tp.0, withArgumentsIn: tp.1 as [Any])

        if isOk {
            let stmt = "SELECT * FROM [\(type(of: model).tableName)] WHERE ROWID = ?"
            if let ret = self.database.executeQuery(stmt, withArgumentsIn: [self.database.lastInsertRowId]), ret.next() {
                model.update(ret.resultDictionary, from: self)
            }
        } else {
            print(self.database.lastError())
        }
        
        return model
    }
    
    
    /// 保存一条数据
    /// - Parameter model:
    @discardableResult
    public func save<T: PKDBModel>(_ model: T) -> Bool {
        return self.recursionSave(model)
    }
    
    
    /// 递归保存数据 如果有外部表数据也一起保存
    /// - Parameter model:
    /// - Returns:
    private func recursionSave(_ model: PKDBModel) -> Bool {
        
        
        let defines = model.extractColumnDefines()
        for define in defines {
            if let m = define.getPropertyValue?() as? PKDBModel {
                if !self.recursionSave(m) {
                    return false
                }
            }
        }
        
        let tp = SQL.update(model)
        
        let isOk = self.database.executeUpdate(tp.0, withArgumentsIn: tp.1 as [Any])
        return isOk
    }
    
    
    /// 删除一条数据
    /// - Parameter model:
    /// - Returns:
    @discardableResult
    public func delete<T: PKDBModel>(_ model: T) -> Bool {
        let statment = SQL.delete(model)
        let isOk = self.database.executeUpdate(statment, withArgumentsIn: [])
        return isOk
    }
    
    /// 删除表中所有数据
    /// - Returns:
    public func deleteTable<T: PKDBModel>(_ cls: T.Type) -> Bool {
        let statment = SQL.deleteTable(cls)
        let isOk = self.database.executeUpdate(statment, withArgumentsIn: [])
        return isOk
    }
    
    /// 删除表
    /// - Parameter cls:
    /// - Returns: 
    public func dropTable<T: PKDBModel>(_ cls: T.Type) -> Bool {
        let statment = SQL.dropTable(cls)
        let isOk = self.database.executeUpdate(statment, withArgumentsIn: [])
        return isOk
    }
    
    /// 最后一次执行错误信息
    /// - Returns:
    public func lastError() -> Error {
        return self.database.lastError()
    }
    
    
    // MARK: - 事务
    @discardableResult
    public func transaction(exec: (_ db: PKDB) -> Error?) -> Bool {
        var isOk = self.database.beginTransaction()
        
        if isOk {
            if exec(self) == nil {
                isOk = self.database.commit()
            } else {
                isOk = self.database.rollback()
            }
        }
        return isOk
    }
}


