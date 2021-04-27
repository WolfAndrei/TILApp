//
//  AcronymsController.swift
//  
//
//  Created by Andrei Volkau on 27.04.2021.
//

import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    /// Lifecycle - conformance to RouteCollection
    func boot(routes: RoutesBuilder) throws {
        
        let acronymRoutes = routes.grouped("api", "acronyms")
        
        /// Create
        acronymRoutes.post(use: createHandler)
        
        /// Retrieve
        acronymRoutes.get(use: getAllHandler)
        acronymRoutes.get(":acronymID", use: getHandler)
        acronymRoutes.get("first", use: getFirstHandler)
        acronymRoutes.get("sorted", use: getSortedHandler)
        
        
        acronymRoutes.get(":acronymID", "user", use: getUserHandler)
        
        
        //working with pivot
        acronymRoutes.get(":acronymID", "categories", use: getCategoriesHandler)
        acronymRoutes.post(":acronymID", "categories", ":categoryID", use: addCategoriesHandler)
        acronymRoutes.delete(":acronymID", "categories", ":categoryID", use: removeCategoriesHandler)
        
        ///Search
        acronymRoutes.get("search", use: searchHandler)
        
        ///Update
        acronymRoutes.put(":acronymID", use: updateHandler)
        
        ///Delete
        acronymRoutes.delete(use: deleteQueryHandler) // /api/acronyms?id=BF82C657-C369-4632-996B-211C5653299B
        acronymRoutes.delete(":acronymID", use: deleteHandler) // /api/acronyms/BF82C657-C369-4632-996B-211C5653299B
    }
    
    /// Query on database
    
    ///GET
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func getFirstHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        Acronym.query(on: req.db).first().unwrap(or: Abort(.notFound))
    }
    
    func getSortedHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).sort(\.$short, .ascending).all()
    }
    
    /// GET - Search
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        guard let searchTerm = try? req.query.get(String.self, at: "term") else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }.all()
    }
    
    ///PUT
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updatedAcronym = try req.content.decode(CreateAcronymData.self)
        return Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (acronym) in
                acronym.short = updatedAcronym.short
                acronym.long = updatedAcronym.long
                acronym.$user.id = updatedAcronym.userID
                return acronym.save(on: req.db).map { acronym }
            }
        /*
         (1) - find existing acronym in db by uuid
         (2) - unwrap it
         (3) - update acronym fields with new parameters
         (4) - save acronym and return it
         */
    }
    
    ///POST
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
        return acronym.save(on: req.db)
                      .map { acronym }
    }
    
    ///DELETE
    func deleteQueryHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = try? req.query.get(String.self, at: "id") else {
            throw Abort(.badRequest)
        }
        
        return   Acronym.find(UUID(id), on: req.db)
                        .unwrap(or: Abort(.notFound))
                        .flatMap { acronym in
                            acronym.delete(on: req.db)
                                .transform(to: .noContent)
                        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return   Acronym.find(req.parameters.get("acronymID"), on: req.db)
                        .unwrap(or: Abort(.notFound))
                        .flatMap { acronym in
                            acronym.delete(on: req.db)
                                .transform(to: .noContent)
                        }
    }
    
    func getUserHandler(_ req: Request) -> EventLoopFuture<User> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db)
            }
    }
    
    func addCategoriesHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
        let categoryQuery = Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound))
        return acronymQuery
            .and(categoryQuery)
            .flatMap { acronym, category in
                acronym
                    .$categories
                    .attach(category, on: req.db)
                    .transform(to: .created)
            }
    }
    
    func getCategoriesHandler(_ req: Request) -> EventLoopFuture<[Category]> {
        Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$categories.query(on: req.db).all()
            }
    }
    
    func removeCategoriesHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
        let categoryQuery = Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound))
        return acronymQuery.and(categoryQuery)
            .flatMap { acronym, category in
                acronym
                    .$categories
                    .detach(category, on: req.db)
                    .transform(to: .noContent)
            }
    }
    
}


struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}
