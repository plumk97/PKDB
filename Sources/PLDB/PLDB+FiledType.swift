//
//  PLDB+FiledType.swift
//  PLDB
//
//  Created by Plumk on 2021/10/14.
//

import Foundation


/// 支持的数据类型
public protocol PLDBFieldType {
    
    /// 在数据库中的类型
    static var sqliteType: String { get }
}

// MARK: - Int
extension Int: PLDBFieldType {
    public static var sqliteType: String { "INTEGER" }
}

extension Int8: PLDBFieldType {
    public static var sqliteType: String { "INTEGER" }
}

extension Int16: PLDBFieldType {
    public static var sqliteType: String { "INTEGER" }
}

extension Int32: PLDBFieldType {
    public static var sqliteType: String { "INTEGER" }
}

extension Int64: PLDBFieldType {
    public static var sqliteType: String { "INTEGER" }
}

// MARK: - Uint
extension UInt: PLDBFieldType {
    public static var sqliteType: String { "INTEGER" }
}

extension UInt8: PLDBFieldType {
    public static var sqliteType: String { "INTEGER" }
}

extension UInt16: PLDBFieldType {
    public static var sqliteType: String { "INTEGER" }
}

extension UInt32: PLDBFieldType {
    public static var sqliteType: String { "INTEGER" }
}

extension UInt64: PLDBFieldType {
    public static var sqliteType: String { "INTEGER" }
}

// MARK: - Float
extension Float: PLDBFieldType {
    public static var sqliteType: String { "REAL" }
}


// MARK: - Double
extension Double: PLDBFieldType {
    public static var sqliteType: String { "REAL" }
}

// MARK: - Bool
extension Bool: PLDBFieldType {
    public static var sqliteType: String { "BOOLEAN" }
}

// MARK: - String
extension String: PLDBFieldType {
    public static var sqliteType: String { "TEXT" }
}


// MARK: - Data
extension Data: PLDBFieldType {
    public static var sqliteType: String { "BLOB" }
}


// MARK: - Date
extension Date: PLDBFieldType {
    public static var sqliteType: String { "REAL" }
}

// MARK: - PLDBModel
extension PLDBModel {
    public static var sqliteType: String {
        return "INTEGER"
    }
}

