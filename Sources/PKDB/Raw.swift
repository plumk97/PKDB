//
//  PKDB+Raw.swift
//  PKDB
//
//  Created by Plumk on 2021/7/29.
//

import Foundation
import GRDB

public protocol RawCreable {
    func raw(_ statment: String) -> Raw
}

/// 执行原始SQL语句
public class Raw {
    
    private let dbInterface: _PKDBInterface
    
    /// SQL语句
    private var statment: String!
    
    init(statment: String, dbInterface: _PKDBInterface) {
        self.dbInterface = dbInterface
        self.statment = statment
    }
    
    func query(database: Database) throws -> RowCursor? {
        try Row.fetchCursor(database, sql: self.statment)
    }
    
    func query<T: PKDBModel>(_ model: T.Type, database: Database) throws -> [T]? {
        guard let ret = try self.query(database: database) else {
            return nil
        }
        
        var models = [T]()
        
        while let row = try ret.next() {
            let m = T()
            let dict = Dictionary(row.map({($0, $1.storage.value as Any)}), uniquingKeysWith: {(left, _) in left})
            m.update(dict, from: database)
            models.append(m)
        }
        return models
    }
    
    // MARK: - Public
    /// 查询
    /// - Returns:
    public func query() throws -> RowCursor? {
        try self.dbInterface.read { db in
            try query(database: db)
        }
    }
    
    public func query<T: PKDBModel>(_ model: T.Type) throws -> [T]? {
        try self.dbInterface.read { db in
            try query(model, database: db)
        }
    }
    
    /// 更新
    /// - Returns:
    public func execute() throws {
        try self.dbInterface.write { db in
            try db.execute(sql: self.statment)
        }
    }
}
