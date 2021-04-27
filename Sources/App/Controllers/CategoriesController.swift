//
//  CategoriesController.swift
//  
//
//  Created by Andrei Volkau on 27.04.2021.
//

import Vapor
import Fluent

struct CategoriesController: RouteCollection {
   
    func boot(routes: RoutesBuilder) throws {
        
        let categoriesRoute = routes.grouped("api", "categories")
        
        categoriesRoute.get(use: getAllCategoriesHandler)
        categoriesRoute.get(":categoryID", use: getCategoryHandler)
        categoriesRoute.post(use: createHandler)
        
        categoriesRoute.get(":categoryID", "acronyms", use: getAcronymsHandler)
    }
    
    func getAllCategoriesHandler(_ req: Request) -> EventLoopFuture<[Category]> {
        Category.query(on: req.db).all()
    }
    
    func getCategoryHandler(_ req: Request) -> EventLoopFuture<Category> {
        Category.find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func createHandler (_ req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        return category.save(on: req.db)
                .map { category }
    }
    
    func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                category.$acronyms.get(on: req.db)
            }
    }
    
    
    
}
