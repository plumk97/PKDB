//
//  ColumnType.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation

/// 数据库支持的字段类型
public enum ColumnType: String {
    
    case INTEGER = "INTEGER"
    case REAL = "REAL"
    case BOOLEAN = "BOOLEAN"
    case TEXT = "TEXT"
    case BLOB = "BLOB"
}
