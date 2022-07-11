//
//  ViewController.swift
//  PLDB
//
//  Created by Plumk on 2021/7/29.
//

import UIKit
import PLDB

struct Address: PLDBModel {
    static var tableName: String { "Address" }
    static var uniqueIdName: String { "id" }
    var uniqueId: Int { self.id }
    
    @Column(primaryKey: true, autoIncrement: true, index: true)
    var id: Int = 0
    
    @Column
    var address = ""
}

struct User: PLDBModel {
    
    static var tableName: String { "User" }
    static var uniqueIdName: String { "id" }
    var uniqueId: Int { self.id }
    
    @Column(primaryKey: true, autoIncrement: true, index: true)
    var id: Int = 0

    @Column
    var name = ""
    
    @Column
    var title = ""
    
    @Column
    var address: Address?
    
    @Column
    var data: Data?
    
    @Column
    var date: Date?
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var models = [User]()
    var db: PLDB!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        print(documentDir)
        self.db = PLDB(path: documentDir + "/test.db")
        if self.db.open() {

            /// - 创建表
            self.db.createTable(User())
            self.db.createTable(Address())

            /// - 读取表中名叫张三的数据
//            if let models = self.db.query(User.self).where("name = ?", "张三").all() {
//                self.models = models
//            }

            /// - 读取表中所有数据
            if let models = self.db.query(User.self).all() {
                self.models = models
            }
        }
        
    }
    
    @IBAction func insertBtnClick(_ sender: UIButton) {
        
        let user = User()
        user.address = Address()
        if arc4random() % 100 > 50 {
            user.name = "张三"
            user.title = "CTO"
            user.address?.address = "深圳市福田区"
        } else {
            user.name = "李四"
            user.title = "CEO"
            user.address?.address = "深圳市南山区"
        }
        
        user.data = "data".data(using: .utf8)!
        
        let model = self.db.create(user)
        print(model)
        self.models.append(model)
        self.tableView.insertRows(at: [IndexPath.init(row: self.models.count - 1, section: 0)], with: .automatic)
    }
    
    @IBAction func updateBtnClick(_ sender: UIButton) {
        guard let ip = self.tableView.indexPathForSelectedRow else {
            return
        }
        
        let model = self.models[ip.row]
        if arc4random() % 100 > 50 {
            model.name = "张三"
            model.title = "CTO"
            model.address?.address = "深圳市福田区1"
        } else {
            model.name = "李四"
            model.title = "CEO"
            model.address?.address = "深圳市南山区1"
        }
        self.db.save(model)
        self.tableView.reloadRows(at: [ip], with: .automatic)
    }
    
    @IBAction func removeBtnClick(_ sender: UIButton) {
        guard let ip = self.tableView.indexPathForSelectedRow else {
            return
        }
        
        let model = self.models[ip.row]
        if let address = model.address {
            print(self.db.delete(address))
        }
        
        print(self.db.delete(model))
        self.models.remove(at: ip.row)
        self.tableView.deleteRows(at: [ip], with: .automatic)
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let model = self.models[indexPath.row]
        cell.textLabel?.text = model.name
        cell.detailTextLabel?.text = model.title + " " + (model.address?.address ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.models[indexPath.row]
        print(model)
    }
}
