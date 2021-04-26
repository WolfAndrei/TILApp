//
//  CreateAcronym.swift
//  
//
//  Created by Andrei Volkau on 23.04.2021.
//

import Fluent

struct CreateAcronym: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Acronym.schema)
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Acronym.schema)
                .delete()
    }
    
}

