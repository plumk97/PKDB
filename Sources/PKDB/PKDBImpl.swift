//
//  File.swift
//  PKDB
//
//  Created by zhu on 2025/3/8.
//

import Foundation
import GRDB


struct PKDBImpl: PKDBInterface {
    
    let database: Database
    init(database: Database) {
        self.database = database
    }
    
    /// 判断表是否存在
    /// - Parameter cls:
    /// - Returns:
    @discardableResult
    public func tableExists(_ cls: PKDBModel.Type) throws -> Bool {
        try database.tableExists(cls.tableName)
    }
    
    /// 创建一张表
    /// - Parameter model:
    /// - Returns:
    public func createTable(_ model: PKDBModel) throws {
        if try self.tableExists(type(of: model)) {
            return
        }
        
        let statemts = SQL.create(model)
        try database.execute(sql: statemts.joined(separator: "\n"))
    }
    
    /// 创建一条数据
    /// - Parameter model:
    /// - Returns:
    public func create<T: PKDBModel>(_ model: T) throws -> T {
        try recursionCreate(model) as! T
    }
    
    
    /// 递归创建数据 如果有引用外部表也一起创建
    /// - Parameter model:
    /// - Returns:
    private func recursionCreate(_ model: PKDBModel) throws -> PKDBModel {
        let defines = model.extractColumnDefines()
        for define in defines {
            if let m = define.getPropertyValue?() as? PKDBModel {
                define.setPropertyValue?(try recursionCreate(m))
            }
        }
        
        let tp = SQL.insert(model)
        try database.execute(sql: tp.0, arguments: .init(tp.1))
        
        
        let stmt = "SELECT * FROM [\(type(of: model).tableName)] WHERE ROWID = ?"
        guard let row = try Row.fetchOne(database, sql: stmt, arguments: [database.lastInsertedRowID]) else {
            throw GRDB.DatabaseError(resultCode: database.lastErrorCode, message: database.lastErrorMessage)
        }
        
        let dict = Dictionary(row.map({($0, $1.storage.value as Any)}), uniquingKeysWith: {(left, _) in left})
        model.update(dict, from: database)
        return model
    }
    
 
    /// 保存一条数据
    /// - Parameter model:
    public func save<T: PKDBModel>(_ model: T) throws {
        try recursionSave(model)
    }
    
    /// 递归保存数据 如果有外部表数据也一起保存
    /// - Parameter model:
    /// - Returns:
    private func recursionSave(_ model: PKDBModel) throws {
        
        let defines = model.extractColumnDefines()
        for define in defines {
            if let m = define.getPropertyValue?() as? PKDBModel {
                try recursionSave(m)
            }
        }
        
        let tp = SQL.update(model)
        try database.execute(sql: tp.0, arguments: .init(tp.1))
    }
    
    
    /// 删除一条数据
    /// - Parameter model:
    /// - Returns:
    public func delete<T: PKDBModel>(_ model: T) throws {
        let statment = SQL.delete(model)
        try database.execute(sql: statment)
    }
    
    /// 删除表中所有数据
    /// - Returns:
    public func deleteTable<T: PKDBModel>(_ cls: T.Type) throws {
        let statment = SQL.deleteTable(cls)
        try database.execute(sql: statment)
    }
    
    /// 删除表
    /// - Parameter cls:
    /// - Returns:
    public func dropTable<T: PKDBModel>(_ cls: T.Type) throws {
        let statment = SQL.dropTable(cls)
        try database.execute(sql: statment)
    }
}


extension PKDBImpl: _PKDBInterface {
    func write<T>(_ value: (GRDB.Database) throws -> T) throws -> T {
        try value(self.database)
    }
    
    func read<T>(_ value: (GRDB.Database) throws -> T) throws -> T {
        try value(self.database)
    }
}


extension PKDBImpl: QueryCreable {
    public func query<T>(_ type: T.Type) -> Query<T> where T : PKDBModel {
        return Query(self)
    }
}

extension PKDBImpl: RawCreable {
    public func raw(_ statment: String) -> Raw {
        Raw(statment: statment, dbInterface: self)
    }
}
