//
//  Models+Testable.swift
//  
//
//  Created by Andrei Volkau on 17.06.2021.
//

@testable import App
import Fluent

extension User {
    /// This function saves a user, created with the supplied details, in the database.
    static func create(name: String = "Luke", username: String = "lukes", on database: Database) throws -> User {
        let user = User(name: name, username: username)
        try user.save(on: database).wait()
        return user
    }
}

extension Acronym {
    /// This creates an acronym and saves it in the database with the provided values.
    static func create(short: String = "TIL", long: String = "Today I Learned", user: User? = nil, on database: Database) throws -> Acronym {
        var acronymUser = user
        
        if acronymUser == nil {
            acronymUser = try User.create(on: database)
        }
        
        let acronym = Acronym(short: short, long: long, userID: acronymUser!.id!)
        try acronym.save(on: database).wait()
        return acronym
    }
}

extension App.Category {
    static func create(name: String = "Random", on database: Database) throws -> Category {
        let category = Category(name: name)
        try category.save(on: database).wait()
        return category
    }
}

extension AcronymCategoryPivot {
    static func create(acronym: Acronym? = nil, category: Category? = nil, on database: Database) throws -> AcronymCategoryPivot {
        var acr = acronym
        var cat = category
        
        if acr == nil {
            acr = try Acronym.create(on: database)
        }
        if cat == nil {
            cat = try Category.create(on: database)
        }
        
        let acronymCategoryPivot = try AcronymCategoryPivot(acronym: acr!, category: cat!)
        try acronymCategoryPivot.save(on: database).wait()
        return acronymCategoryPivot
    }
}
