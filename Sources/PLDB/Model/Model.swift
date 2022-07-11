//
//  PLDB+Model.swift
//  PLDB
//
//  Created by Plumk on 2021/7/28.
//

import Foundation


/// 数据表模型
public protocol PLDBModel {
    init()
    
    /// 唯一Id 用于更新删除 返回字段名 字段值
    var uniqueId: (String, Int) { get }
    
    /// 表名
    static var tableName: String { get }
}

