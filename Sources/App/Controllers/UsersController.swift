//
//  UsersController.swift
//  
//
//  Created by Andrei Volkau on 27.04.2021.
//

import Vapor
import Fluent

struct UsersController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        let userRoute = routes.grouped("api", "users")
        
        userRoute.post(use: createHandler)
        userRoute.get("all", use: getAllHandler)
        userRoute.get(use: getHandler)
        userRoute.get(":userID", "acronyms", use: getAcronymsHandler)
    }
    
    // Create new user (POST)
    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }
    
    // Get all users (GET)
    func getAllHandler(_ req: Request) -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    
    // Get user by its ID (GET)
    func getHandler(_ req: Request) throws -> EventLoopFuture<User> {
        guard let userID = try? req.query.get(String.self, at: "id") else {
            throw Abort(.badRequest)
        }
        return User
            .find(UUID(userID), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    // Get all acronyms of user
    func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$acronyms.get(on: req.db)
            }
    }
    
}
