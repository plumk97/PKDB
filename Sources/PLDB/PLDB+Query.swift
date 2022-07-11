//
//  PLDB+Query.swift
//  PLDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation
import FMDB

extension PLDB {
    public class Query<T: PLDBModel> {
        
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
        
        private var database: FMDatabase!
        private var conditions = [Condition]()
        private var orderBy: OrderBy?
        private var limitNum: Int?
        private var offsetNum: Int?
        
        fileprivate init(database: FMDatabase) {
            self.database = database
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
        
        /// 递归查询外部引用
        /// - Parameter model:
        private func recursionQueryExternalTable(_ model: PLDBModel, resultDictionary: [AnyHashable: Any]?) {
            guard let resultDictionary = resultDictionary else {
                return
            }
 
            let defines = model.extractColumnDefines()
            for define in defines {
                if let m = define.getPropertyValue?() as? PLDBModel {
                    
                    let tableName = type(of: m).tableName
                    let uniqueId = m.uniqueId
                    
                    guard let id = resultDictionary[uniqueId.0] as? Int else {
                        continue
                    }
                    
                    guard let ret = self.database.executeQuery("SELECT * FROM \(tableName) WHERE \(uniqueId.0) = ?", withArgumentsIn: [id]),
                          ret.next() else {
                        continue
                    }
                    
                    m.update(ret.resultDictionary)
                    self.recursionQueryExternalTable(m, resultDictionary: resultDictionary)
                }
            }
        }
        
        /// 取数量
        /// - Returns:
        public func count() -> Int {
            
            let tp = self.combine(preStatment: "SELECT COUNT(*) FROM '\(T.tableName)'")
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
            
            let tp = self.combine(preStatment: "SELECT * FROM '\(T.tableName)'")
            guard let ret = self.database.executeQuery(tp.0, withArgumentsIn: tp.1),
                  ret.next() else {
                return nil
            }
            
            let model = T.init()
            model.update(ret.resultDictionary)
            self.recursionQueryExternalTable(model, resultDictionary: ret.resultDictionary)
            return model
        }
        
        
        /// 取当前查询语句最后一个
        /// - Returns:
        public func last() -> T? {
            _ = self.order(by: "ROWID", order: .desc)
            _ = self.limit(1)
            
            let tp = self.combine(preStatment: "SELECT * FROM '\(T.tableName)'")
            guard let ret = self.database.executeQuery(tp.0, withArgumentsIn: tp.1),
                  ret.next() else {
                return nil
            }
            
            let model = T.init()
            model.update(ret.resultDictionary)
            self.recursionQueryExternalTable(model, resultDictionary: ret.resultDictionary)
            return model
        }
        
        
        /// 取当前查询语句所有值
        /// - Returns:
        public func all() -> [T]? {
            
            let tp = self.combine(preStatment: "SELECT * FROM '\(T.tableName)'")
            guard let ret = self.database.executeQuery(tp.0, withArgumentsIn: tp.1) else {
                return nil
            }
            
            var models = [T]()
            
            while ret.next() {
                let m = T()
                m.update(ret.resultDictionary)
                self.recursionQueryExternalTable(m, resultDictionary: ret.resultDictionary)
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
    public func query<T: PLDBModel>(_ type: T.Type) -> Query<T> {
        return Query<T>(database: self.database)
    }
}
