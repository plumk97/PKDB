//
//  CURDTests.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import XCTest
@testable import PKDB

enum Gender: Int, PKDBEnum {
    case woman = 0
    case man = 1
}

struct User: PKDBModel {
    
    /// 表名
    static var tableName: String { "users" }
    
    /// 唯一id
    static var uniqueIdName: String { "id" }
    var uniqueId: Int { self.id }
    
    @Column(primaryKey: true, autoIncrement: true, index: true)
    var id = 0
    
    @Column
    var gender = Gender.man
    
    @Column
    var name: String?
    
    @Column
    var pet: Pet?
    
    @Column
    var bool: Bool?
    
    @Column
    var data: Data?
    
    @Column
    var date: Date?
    
    @Column
    var float: Float?
    
    @Column
    var double: Double?
    
}

struct Pet: PKDBModel {
    
    /// 表名
    static var tableName: String { "pets" }
    
    /// 唯一id
    static var uniqueIdName: String { "id" }
    var uniqueId: Int { self.id }
    
    @Column(primaryKey: true, autoIncrement: true, index: true)
    var id = 0
    
    @Column
    var name: String?
    
}


final class CURDTests: XCTestCase {
    
    func databasePath() -> String {
        var path = FileManager.default.homeDirectoryForCurrentUser
        path.appendPathComponent("pk_test.db")
//        try? FileManager.default.removeItem(at: path)
        return path.relativePath
    }
    
    func createDB() throws -> PKDB {
        let db = try PKDB(path: databasePath())
        try db.createTable(User())
        try db.createTable(Pet())
        return db
    }
    
    func testCreate() throws {
        _ = try createDB()
    }
    
    
    func insertOneData() throws {
        let db = try createDB()
        let user = try db.create(User(
            name: "xxx",
            pet: Pet(name: "dog"),
            bool: true,
            data: "sadd".data(using: .utf8),
            date: Date(),
            float: 1.23,
            double: 3.21
        ))
        print(user)
    }
    
    
    func testInsert() throws {
        _ = try insertOneData()
    }
    
    func testBatchInsert() throws {
        let db = try createDB()
        for i in 1 ... 10000 {
            _ = try db.create(User(name: "user_\(i)"))
        }
    }
    
    func testBatchInsert_Transaction() throws {
        let db = try createDB()
        try db.batch { db in
            let model = try db.query(User.self).first()
            print(model)
//            for i in 1 ... 10000 {
//                _ = try db.create(User(name: "user_\(i)"))
//            }
        }
    }
    
    func testQuery() throws {
    
        let db = try createDB()
        if let model = try db.query(User.self).get(5) {
            print(model)
        }
        
        if let user = try db.query(User.self).where("name = ?", "xxx").last() {
            print(user)
        }
        
        let users = try db.query(User.self).where("name = ?", "xxx").all()
        print(users)
    }
    
    func testDelete() throws {
        let db = try createDB()
        
        if let user = try db.query(User.self).first() {
            try db.delete(user)
        }
    }
    
    func testDeleteTable() throws {
        let db = try createDB()
        try db.deleteTable(User.self)
    }
    
    func testUpdate() throws {
        let db = try createDB()
        if let user = try db.query(User.self).first() {
            user.pet?.name = "fff"
            user.name = "zzz"
            try db.save(user)
        }
    }
    
    func testRaw() throws {
        let db = try createDB()
        
        guard let models = try db.raw("SELECT * FROM users").query(User.self) else {
            fatalError()
        }
        print(models.last)
    }
}
