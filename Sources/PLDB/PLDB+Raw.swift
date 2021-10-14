//
//  PLDB+Raw.swift
//  PLDB
//
//  Created by Plumk on 2021/7/29.
//

import Foundation
import FMDB

extension PLDB {
    
    public class Raw {
        
        private var statment: String!
        private var database: FMDatabase!
        
        fileprivate init(statment: String, database: FMDatabase) {
            self.statment = statment
            self.database = database
        }
        
        public func query() -> FMResultSet? {
            return self.database.executeQuery(self.statment, withArgumentsIn: [])
        }
        
        public func update() -> Bool {
            return self.database.executeUpdate(self.statment, withArgumentsIn: [])
        }
        
        public func exec(_ complete: (([AnyHashable: Any]) -> Void)?) -> Bool {
            return self.database.executeStatements(self.statment) {
                complete?($0)
                return 1
            }
        }
    }
    
    public func raw(_ statment: String) -> Raw {
        return Raw(statment: statment, database: self.database)
    }
}
