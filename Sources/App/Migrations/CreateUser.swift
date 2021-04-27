//
//  CreateUser.swift
//  
//
//  Created by Andrei Volkau on 27.04.2021.
//

import Vapor
import Fluent

class CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
                .delete()
    }
}
