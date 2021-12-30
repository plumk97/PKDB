//
//  PLDB.swift
//  PLDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation
import FMDB

public class PLDB {
    
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
    public func tableExists(_ cls: PLDBModel.Type) -> Bool {
        return self.database.tableExists(cls.tableName)
    }
    
    /// 创建一张表
    /// - Parameter model:
    /// - Returns:
    @discardableResult
    public func createTable(_ model: PLDBModel) -> Bool {
        if self.tableExists(type(of: model)) {
            return true
        }
        
        let statemts = SQL.create(type(of: model).tableName, descriptions: model.extractFields())
        return self.database.executeStatements(statemts.joined(separator: "\n"))
    }
    
    /// 创建一条数据
    /// - Parameter model:
    /// - Returns:
    public func create<T: PLDBModel>(_ model: T) -> T {
        return self.recursionCreate(model) as! T
    }
    
    
    /// 递归创建数据 如果有引用外部表也一起创建
    /// - Parameter model:
    /// - Returns:
    private func recursionCreate(_ model: PLDBModel) -> PLDBModel {
        let fds = model.extractFields()
        for fd in fds {
            if let m = fd.getValue() as? PLDBModel {
                fd.setValue(self.recursionCreate(m))
            }
        }
        
        let tp = SQL.insert(model)

        let isOk = self.database.executeUpdate(tp.0, withArgumentsIn: tp.1 as [Any])

        if isOk {
            if let ret = self.database.executeQuery("SELECT * FROM '\(type(of: model).tableName)' WHERE ROWID = ?", withArgumentsIn: [self.database.lastInsertRowId]), ret.next() {
                model.update(ret.resultDictionary)
            }
        } else {
            print(self.database.lastError())
        }
        
        return model
    }
    
    
    /// 保存一条数据
    /// - Parameter model:
    @discardableResult
    public func save<T: PLDBModel>(_ model: T) -> Bool {
        return self.recursionSave(model)
    }
    
    
    /// 递归保存数据 如果有外部表数据也一起保存
    /// - Parameter model:
    /// - Returns:
    private func recursionSave(_ model: PLDBModel) -> Bool {
        
        let fds = model.extractFields()
        for fd in fds {
            if let m = fd.getValue() as? PLDBModel {
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
    public func delete<T: PLDBModel>(_ model: T) -> Bool {
        let statment = SQL.delete(model)
        let isOk = self.database.executeUpdate(statment, withArgumentsIn: [])
        return isOk
    }
    
    
    /// 最后一次执行错误信息
    /// - Returns:
    public func lastError() -> Error {
        return self.database.lastError()
    }
    
    
    // MARK: - 事务
    public func beginTransaction() -> Bool {
        return self.database.beginTransaction()
    }
    
    public func rollback() -> Bool {
        return self.database.rollback()
    }
    
    
    public func commit() -> Bool {
        return self.database.commit()
    }
    
}


