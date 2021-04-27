//
//  CreateCategory.swift
//  
//
//  Created by Andrei Volkau on 27.04.2021.
//

import Vapor
import Fluent

struct CreateCategory: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Category.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Category.schema)
            .delete()
    }
    
}
