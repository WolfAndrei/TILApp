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
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<User> {
        guard let userID = try? req.query.get(String.self, at: "id") else {
            throw Abort(.badRequest)
        }
        return User
            .find(UUID(userID), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$acronyms.get(on: req.db)
            }
    }
    
}
