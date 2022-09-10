//
//  PLDB+Raw.swift
//  PLDB
//
//  Created by Plumk on 2021/7/29.
//

import Foundation
import FMDB

extension PLDB {
    
    /// 执行原始SQL语句
    public class Raw {
        
        /// SQL语句
        private var statment: String!
        
        /// 数据库对象
        private var db: PLDB!
        
        private var database: FMDatabase {
            return self.db.database
        }
        
        fileprivate init(statment: String, db: PLDB) {
            self.statment = statment
            self.db = db
        }
        
        /// 查询
        /// - Returns:
        public func query() -> FMResultSet? {
            return self.database.executeQuery(self.statment, withArgumentsIn: [])
        }
        
        public func query<T: PLDBModel>(_ model: T.Type) -> [T]? {
            guard let ret = self.query() else {
                return nil
            }
            
            var models = [T]()
            while ret.next() {
                
                let model = T.init()
                model.update(ret.resultDictionary, from: self.db)
                models.append(model)
            }
            return models
        }
        
        /// 更新
        /// - Returns:
        public func update() -> Bool {
            return self.database.executeUpdate(self.statment, withArgumentsIn: [])
        }
        
        /// 执行
        /// - Parameter complete: 
        /// - Returns: 返回结果
        public func exec(_ complete: (([AnyHashable: Any]) -> Void)?) -> Bool {
            return self.database.executeStatements(self.statment) {
                complete?($0)
                return 1
            }
        }
    }
    
    /// 开启执行原始语句
    /// - Parameter statment:
    /// - Returns:
    public func raw(_ statment: String) -> Raw {
        return Raw(statment: statment, db: self)
    }
}
