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
        
        /// FMDB对象
        private var database: FMDatabase!
        
        fileprivate init(statment: String, database: FMDatabase) {
            self.statment = statment
            self.database = database
        }
        
        /// 查询
        /// - Returns:
        public func query() -> FMResultSet? {
            return self.database.executeQuery(self.statment, withArgumentsIn: [])
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
        return Raw(statment: statment, database: self.database)
    }
}
