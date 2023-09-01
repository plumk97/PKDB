//
//  PKDB+Query.swift
//  PKDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation
import FMDB

extension PKDB {
    
    /// 查询语句对象化
    public class Query<T: PKDBModel> {
        
        private struct Condition {
            let statment: String
            let values: [Any?]
        }
        
        public enum Order {
            case asc
            case desc
        }
        
        private struct OrderBy {
            let by: [String]
            let order: Order
        }
        
        
        /// where 条件语句
        private var conditions = [Condition]()
        
        /// 排序
        private var orderBy: OrderBy?
        
        /// 限制数量
        private var limitNum: Int?
        
        /// 查询偏移
        private var offsetNum: Int?
        
        /// PKDB对象
        private var db: PKDB
        
        /// FMDB对象
        private var database: FMDatabase {
            return self.db.database
        }
        
        fileprivate init(db: PKDB) {
            self.db = db
        }
        
        
        /// 组合查询语句 加入条件
        /// - Parameter preStatment:
        /// - Returns:
        private func combine(preStatment: String) -> (String, [Any]) {
            
            var statment = preStatment
            
            var args = [Any?]()
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
            
            return (statment, args as [Any])
        }
        
        /// 取数量
        /// - Returns:
        public func count() -> Int {
            
            let tp = self.combine(preStatment: "SELECT COUNT(*) FROM [\(T.tableName)]")
            guard let ret = self.database.executeQuery(tp.0, withArgumentsIn: tp.1),
                  ret.next() else {
                return 0
            }
            
            return Int(ret.int(forColumnIndex: 0))
        }
        
        /// 取当前查询语句第一个
        /// - Returns:
        public func first() -> T? {
            _ = self.order(by: "ROWID", order: .asc)
            _ = self.limit(1)
            
            let tp = self.combine(preStatment: "SELECT * FROM [\(T.tableName)]")
            guard let ret = try? self.database.executeQuery(tp.0, values: tp.1),
                  ret.next() else {
                return nil
            }
            
            let model = T.init()
            model.update(ret.resultDictionary, from: self.db)
            return model
        }
        
        
        /// 取当前查询语句最后一个
        /// - Returns:
        public func last() -> T? {
            _ = self.order(by: "ROWID", order: .desc)
            _ = self.limit(1)
            
            let tp = self.combine(preStatment: "SELECT * FROM [\(T.tableName)]")
            guard let ret = self.database.executeQuery(tp.0, withArgumentsIn: tp.1),
                  ret.next() else {
                return nil
            }
            
            let model = T.init()
            model.update(ret.resultDictionary, from: self.db)
            return model
        }
        
        
        /// 取当前查询语句所有值
        /// - Returns:
        public func all() -> [T]? {
            
            let tp = self.combine(preStatment: "SELECT * FROM [\(T.tableName)]")
            guard let ret = self.database.executeQuery(tp.0, withArgumentsIn: tp.1) else {
                return nil
            }
            
            var models = [T]()
            
            while ret.next() {
                let m = T()
                m.update(ret.resultDictionary, from: self.db)
                models.append(m)
            }
            
            return models
        }
        
        /// 编写查询条件
        /// - Parameters:
        ///   - statment:
        ///   - values:
        /// - Returns:
        public func `where`(_ statment: String, _ values: Any?...) -> Query {
            
            if let x = values.first as? Array<Any>, values.count == 1 {
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
    
    
    /// 开启查询
    /// - Parameter type:
    /// - Returns:
    public func query<T: PKDBModel>(_ type: T.Type) -> Query<T> {
        return Query<T>(db: self)
    }
}
