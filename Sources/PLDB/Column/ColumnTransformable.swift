//
//  ColumnTransformable.swift
//  
//
//  Created by litiezhu on 2022/7/11.
//

import Foundation


protocol ColumnTransformable {
    static var columnType: ColumnType { get }
    static func transformFromColumnValue(_ value: Any) -> Self?
    func transformToColumnValue() -> Any?
}

