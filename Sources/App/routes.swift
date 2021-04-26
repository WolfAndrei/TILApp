import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    //MARK: - CRUD
    
    ///Create
    app.post("api", "acronyms") { req -> EventLoopFuture<Acronym> in
        let acronym = try req.content.decode(Acronym.self)
        return acronym.save(on: req.db)
                      .map { return acronym }
    }

    ///Retrieve
    app.get("api", "acronyms") { req -> EventLoopFuture<[Acronym]> in
        Acronym.query(on: req.db).all()
    }
    
    app.get("api", "acronyms", ":acronymID") { req -> EventLoopFuture<Acronym> in
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    app.get("api", "acronyms", "first") { req -> EventLoopFuture<Acronym> in
        Acronym.query(on: req.db).first().unwrap(or: Abort(.notFound))
    }
    
    app.get("api", "acronyms", "sorted") { req -> EventLoopFuture<[Acronym]> in
        Acronym.query(on: req.db).sort(\.$short, .ascending).all()
    }
    
    ///Search
    app.get("api", "acronyms", "search") { (req) -> EventLoopFuture<[Acronym]> in
        guard let searchTerm = try? req.query.get(String.self, at: "term") else {
            throw Abort(.badRequest)
        }
        return Acronym
            .query(on: req.db)
            .group(.or) { or in //.and
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }.all()
    }
    
    ///Update
    app.put("api", "acronyms", ":acronymID") { req -> EventLoopFuture<Acronym> in
        let updatedAcronym = try req.content.decode(Acronym.self)
        return Acronym
                .find(req.parameters.get("acronymID"), on: req.db)
                .unwrap(or: Abort(.notFound )).flatMap { acronym in
                    acronym.short = updatedAcronym.short
                    acronym.long = updatedAcronym.long
                    return acronym.save(on: req.db).map { acronym }
                }
        /*
         (1) - find existing acronym in db by uuid
         (2) - unwrap it
         (3) - update acronym fields with new parameters
         (4) - save acronym and return it
         */
    }
    
    ///Delete
    /// /api/acronyms/BF82C657-C369-4632-996B-211C5653299B
    app.delete("api","acronyms") { (req) -> EventLoopFuture<HTTPStatus> in
        guard let queryId = try? req.query.get(String.self, at: "id") else {
            throw Abort(.badRequest)
        }
        return Acronym
            .find(UUID(queryId), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    /// /api/acronyms?id=BF82C657-C369-4632-996B-211C5653299B
    app.delete("api","acronyms", ":acronymID") { (req) -> EventLoopFuture<HTTPStatus> in
        Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
}
