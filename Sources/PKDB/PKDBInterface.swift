//
//  PKDBInterface.swift
//  PKDB
//
//  Created by Plumk on 2025/3/8.
//

import Foundation
import GRDB

public protocol PKDBInterface: QueryCreable, RawCreable {
    
    /// 判断表是否存在
    /// - Parameter cls:
    /// - Returns:
    func tableExists(_ cls: PKDBModel.Type) throws -> Bool
    
    /// 创建表
    /// - Parameter model:
    func createTable(_ model: PKDBModel) throws
    
    /// 创建数据
    /// - Parameter model:
    /// - Returns:
    func create<T: PKDBModel>(_ model: T) throws -> T
    
    /// 更新数据
    /// - Parameter model:
    func save<T: PKDBModel>(_ model: T) throws
    
    /// 删除一条数据
    /// - Parameter model:
    func delete<T: PKDBModel>(_ model: T) throws
    
    /// 清空表数据
    /// - Parameter cls:
    func deleteTable<T: PKDBModel>(_ cls: T.Type) throws
    
    /// 删除表
    /// - Parameter cls:
    func dropTable<T: PKDBModel>(_ cls: T.Type) throws
}

protocol _PKDBInterface {
    
    /// 开启写入
    /// - Parameter value:
    /// - Returns:
    func write<T>(_ value: (Database) throws -> T) throws -> T
    
    /// 开启读取
    /// - Parameter value:
    /// - Returns: 
    func read<T>(_ value: (Database) throws -> T) throws -> T
}
