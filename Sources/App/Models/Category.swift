//
//  Category.swift
//  
//
//  Created by Andrei Volkau on 27.04.2021.
//

import Vapor
import Fluent

final class Category: Model, Content {
    
    static let schema = "categories"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Siblings(through: AcronymCategoryPivot.self, from: \.$category, to: \.$acronym)
    var acronyms: [Acronym]
    
    init() { }
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
}
