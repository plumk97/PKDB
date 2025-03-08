//
//  PKDB+Query.swift
//  PKDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation
import GRDB


public protocol QueryCreable {
    /// 开启查询
    /// - Parameter type:
    /// - Returns:
    func query<T: PKDBModel>(_ type: T.Type) -> Query<T>
}

/// 查询语句对象化
public class Query<T: PKDBModel> {
    
    private struct Condition {
        let statment: String
        let values: [DatabaseValueConvertible?]
    }
    
    public enum Order {
        case asc
        case desc
    }
    
    private struct OrderBy {
        let by: [String]
        let order: Order
    }
    
    ///
    private let database: Database?
    
    ///
    private let dbInterface: _PKDBInterface?
    
    /// where 条件语句
    private var conditions = [Condition]()
    
    /// 排序
    private var orderBy: OrderBy?
    
    /// 限制数量
    private var limitNum: Int?
    
    /// 查询偏移
    private var offsetNum: Int?
    
    
    init(_ database: Database) {
        self.database = database
        self.dbInterface = nil
    }
    
    init(_ dbInterface: _PKDBInterface) {
        self.dbInterface = dbInterface
        self.database = nil
    }
    
    
    /// 组合查询语句 加入条件
    /// - Parameter preStatment:
    /// - Returns:
    private func combine(preStatment: String) -> (String, [DatabaseValueConvertible]) {
        
        var statment = preStatment
        
        var args = [DatabaseValueConvertible?]()
        if self.conditions.count > 0 {
            statment += " WHERE"
            for condition in self.conditions {
                statment += " " + condition.statment
                args.append(contentsOf: condition.values)
            }
        }
        
        if let orderBy = self.orderBy {
            statment += " ORDER BY " + orderBy.by.joined(separator: ",")
            statment += " " + (orderBy.order == .asc ? "ASC" : "DESC")
        }
        
        if let limitNum = self.limitNum {
            statment += " LIMIT \(limitNum)"
        }
        
        if let offsetNum = self.offsetNum {
            statment += " OFFSET \(offsetNum)"
        }
        
        return (statment, args.filter({ $0 != nil }).map({ $0! }))
    }
    
    /// 取数量
    /// - Returns:
    func count(database: Database) throws -> Int? {
        let tp = self.combine(preStatment: "SELECT COUNT(*) FROM [\(T.tableName)]")
        return try Int.fetchOne(database, sql: tp.0, arguments: .init(tp.1))
    }
    
    
    /// 通过Id取值
    func get(database: Database, id: Int) throws -> T? {
        _ = self.where("\(T.uniqueIdName) = ?", id)
        let tp = self.combine(preStatment: "SELECT * FROM [\(T.tableName)]")
        guard let row = try Row.fetchOne(database, sql: tp.0, arguments: .init(tp.1)) else {
            return nil
        }
        
        let dict = Dictionary(row.map({($0, $1.storage.value as Any)}), uniquingKeysWith: {(left, _) in left})
        let model = T.init()
        model.update(dict, from: database)
        return model
    }
    
    /// 取当前查询语句第一个
    /// - Returns:
    func first(database: Database) throws -> T? {
        _ = self.order(by: "ROWID", order: .asc)
        _ = self.limit(1)
        
        let tp = self.combine(preStatment: "SELECT * FROM [\(T.tableName)]")
        guard let row = try Row.fetchOne(database, sql: tp.0, arguments: .init(tp.1)) else {
            return nil
        }
        
        let dict = Dictionary(row.map({($0, $1.storage.value as Any)}), uniquingKeysWith: {(left, _) in left})
        let model = T.init()
        model.update(dict, from: database)
        return model
    }
    
    
    /// 取当前查询语句最后一个
    /// - Returns:
    func last(database: Database) throws -> T? {
        _ = self.order(by: "ROWID", order: .desc)
        _ = self.limit(1)
        
        let tp = self.combine(preStatment: "SELECT * FROM [\(T.tableName)]")
        guard let row = try Row.fetchOne(database, sql: tp.0, arguments: .init(tp.1)) else {
            return nil
        }
        
        let dict = Dictionary(row.map({($0, $1.storage.value as Any)}), uniquingKeysWith: {(left, _) in left})
        let model = T.init()
        model.update(dict, from: database)
        return model
    }
    
    
    /// 取当前查询语句所有值
    /// - Returns:
    func all(database: Database) throws -> [T] {
        
        let tp = self.combine(preStatment: "SELECT * FROM [\(T.tableName)]")
        let rows = try Row.fetchAll(database, sql: tp.0, arguments: .init(tp.1))
                    
        var models = [T]()
        for row in rows {
            let m = T()
            let dict = Dictionary(row.map({($0, $1.storage.value as Any)}), uniquingKeysWith: {(left, _) in left})
            m.update(dict, from: database)
            models.append(m)
        }
        return models
    }
    
    // MARK: - Public
    /// 取数量
    /// - Returns:
    public func count() throws -> Int? {
        if let database = self.database {
            try self.count(database: database)
        } else {
            try self.dbInterface?.read({ try self.count(database: $0 ) })
        }
        
    }
    
    /// 通过Id取值
    public func get(_ id: Int) throws -> T? {
        if let database = self.database {
            try self.get(database: database, id: id)
        } else {
            try self.dbInterface?.read({ try self.get(database: $0, id: id) })
        }
    }
    
    /// 取当前查询语句第一个
    /// - Returns:
    public func first() throws -> T? {
        if let database = self.database {
            try self.first(database: database)
        } else {
            try self.dbInterface?.read({ try self.first(database: $0 ) })
        }
    }
    
    /// 取当前查询语句最后一个
    /// - Returns:
    public func last() throws -> T? {
        if let database = self.database {
            try self.last(database: database)
        } else {
            try self.dbInterface?.read({ try self.last(database: $0 ) })
        }
    }
    
    
    /// 取当前查询语句所有值
    /// - Returns:
    public func all() throws -> [T] {
        if let database = self.database {
            try self.all(database: database)
        } else {
            try self.dbInterface!.read({ try self.all(database: $0 ) })
        }
    }
    
    
    /// 编写查询条件
    /// - Parameters:
    ///   - statment:
    ///   - values:
    /// - Returns:
    public func `where`(_ statment: String, _ values: DatabaseValueConvertible?...) -> Query {
        
        if let x = values.first as? Array<DatabaseValueConvertible>, values.count == 1 {
            self.conditions.append(.init(statment: statment, values: x))
        } else {
            self.conditions.append(.init(statment: statment, values: values))
        }
        return self
    }
    
    /// 排序
    /// - Parameters:
    ///   - by:
    ///   - order:
    /// - Returns:
    public func order(by: String..., order: Order) -> Query {
        self.orderBy = .init(by: by, order: order)
        return self
    }
    
    
    /// 限制数量
    /// - Parameter n:
    /// - Returns:
    public func limit(_ n: Int) -> Query {
        self.limitNum = n
        return self
    }
    
    /// 偏移数量
    /// - Parameter n:
    /// - Returns:
    public func offset(_ n: Int) -> Query {
        self.offsetNum = n
        return self
    }
}
