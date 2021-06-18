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
    
    @ID                                     // @ID = .init(key: .id) --- it identifies that we use exactly 'id' key
    var id: UUID?
    
    @Field(key: "short")                    // key - is a name of the column in db!
    var short: String
    
    @Field(key: "long")                     // key - is a name of the column in db!
    var long: String
    
    @Parent(key: "userID")
    var user: User
    
    @Siblings(through: AcronymCategoryPivot.self, from: \.$acronym, to: \.$category)
    var categories: [Category]
    
    init() { }                              // required by Model
    
    init(id: UUID? = nil, short: String, long: String, userID: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID
    }
}

//In Vapor 4, Codable makes this trivial. Vapor provides Content, a wrapper around Codable, which allows you to convert models and other data between various formats.
extension Acronym: Content { }
