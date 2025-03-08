//
//  PKDB.swift
//  PKDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation
import GRDB

public class PKDB {
    
    private(set) var dbQueue: DatabaseQueue!
    
    
    public init(path: String) throws {
        self.dbQueue = try DatabaseQueue(path: path)
    }
    
    /// 关闭数据库
    /// - Returns:
    public func close() throws {
        try self.dbQueue.close()
    }
    
    public func batch(_ execute: (_ db: PKDBInterface) throws -> Void) throws {
        try self.dbQueue.write {
            try execute(PKDBImpl(database: $0))
        }
    }
}

extension PKDB: PKDBInterface {
 
    public func tableExists(_ cls: any PKDBModel.Type) throws -> Bool {
        try self.dbQueue.read({
            try PKDBImpl(database: $0).tableExists(cls)
        })
    }
    
    public func createTable(_ model: any PKDBModel) throws {
        try self.dbQueue.write({
            try PKDBImpl(database: $0).createTable(model)
        })
    }
    
    public func create<T>(_ model: T) throws -> T where T : PKDBModel {
        try self.dbQueue.write({
            try PKDBImpl(database: $0).create(model)
        })
    }
    
    public func save<T>(_ model: T) throws where T : PKDBModel {
        try self.dbQueue.write({
            try PKDBImpl(database: $0).save(model)
        })
    }
    
    public func delete<T>(_ model: T) throws where T : PKDBModel {
        try self.dbQueue.write({
            try PKDBImpl(database: $0).delete(model)
        })
    }
    
    public func deleteTable<T>(_ cls: T.Type) throws where T : PKDBModel {
        try self.dbQueue.write({
            try PKDBImpl(database: $0).deleteTable(cls)
        })
    }
    
    public func dropTable<T>(_ cls: T.Type) throws where T : PKDBModel {
        try self.dbQueue.write({
            try PKDBImpl(database: $0).dropTable(cls)
        })
    }
}

extension PKDB: _PKDBInterface {
    func write<T>(_ value: (Database) throws -> T) throws -> T {
        try self.dbQueue.write(value)
    }
    
    func read<T>(_ value: (Database) throws -> T) throws -> T {
        try self.dbQueue.read(value)
    }
}


extension PKDB: QueryCreable {
    public func query<T>(_ type: T.Type) -> Query<T> where T : PKDBModel {
        return Query(self)
    }
}


extension PKDB: RawCreable {
    public func raw(_ statment: String) -> Raw {
        Raw(statment: statment, dbInterface: self)
    }
}
