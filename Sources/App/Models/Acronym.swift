//
//  Acronym.swift
//  
//
//  Created by Andrei Volkau on 23.04.2021.
//

import Vapor
import Fluent

final class Acronym: Model {
    static let schema = "acronyms"          //table name in db
    
    @ID                    // @ID = .init(key: .id) == FieldKey(stringLiteral: "id")--- it identifies that we use namely 'id' key
    var id: UUID?
    
    @Field(key: "short")                    // key - is a name of the column in db!
    var short: String
    
    @Field(key: "long")                     // key - is a name of the column in db!
    var long: String
    
    init() { }                              // required by Model
    
    init(id: UUID? = nil, short: String, long: String) {
        self.id = id
        self.short = short
        self.long = long
    }
}

extension Acronym: Content { }
