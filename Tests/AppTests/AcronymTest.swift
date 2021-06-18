//
//  AcronymTest.swift
//  
//
//  Created by Andrei Volkau on 17.06.2021.
//

@testable import App
import XCTVapor

class AcronymTest: XCTestCase {
    
    var app: Application!
    let acronymBaseURI = "/api/acronyms"
    
    let acronymShort = "OMG"
    let acronymLong = "Oh My God"
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testCreateAcronym() throws {
        let user = try User.create(on: app.db)
        let acronym = CreateAcronymData(short: "OMG", long: "Oh My God", userID: user.id!)
        
        try app.test(.POST, "\(acronymBaseURI)/",
                     beforeRequest: { req in
                        try req.content.encode(acronym)
                     },
                     afterResponse: { response in
                        XCTAssertEqual(response.status, .ok)
                        let receivedAcronym = try response.content.decode(Acronym.self)
                        
                        XCTAssertEqual(receivedAcronym.short, acronym.short)
                        XCTAssertEqual(receivedAcronym.long, acronym.long)
                        XCTAssertNotNil(receivedAcronym.id)
                     })
    }
    
    func testGettingAllAcronyms() throws {
        let user = try User.create(on: app.db)
        let acronym1 = try Acronym.create(short: "OMG", long: "Oh My God", user: user, on: app.db)
        let _ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: app.db)
        
        try app.test(.GET, acronymBaseURI, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let acronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(acronyms.count, 2)
            XCTAssertEqual(acronyms[0].id, acronym1.id)
            XCTAssertEqual(acronyms[0].short, acronym1.short)
            XCTAssertEqual(acronyms[0].long, acronym1.long)
        })
    }
    
    func testGettingAcronymByID() throws {
        let acronym = try Acronym.create(on: app.db)
        
        try app.test(.GET, "\(acronymBaseURI)/\(acronym.id!)", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let receivedAcronym = try response.content.decode(Acronym.self)
            
            XCTAssertEqual(acronym.id, receivedAcronym.id)
            XCTAssertEqual(acronym.short, receivedAcronym.short)
            XCTAssertEqual(acronym.long, receivedAcronym.long)
        })
    }
    
    func testGettingFirstAcronym() throws {
        let user = try User.create(on: app.db)
        let acronym1 = try Acronym.create(short: "OMG", long: "Oh My God", user: user, on: app.db)
        let _ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: app.db)
        
        try app.test(.GET, "\(acronymBaseURI)/first", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let receivedAcronym = try response.content.decode(Acronym.self)
            
            XCTAssertEqual(receivedAcronym.id, acronym1.id)
            XCTAssertEqual(receivedAcronym.short, acronym1.short)
            XCTAssertEqual(receivedAcronym.long, acronym1.long)
        })
    }
    
    func testGettingSortedAcronyms() throws {
        let user = try User.create(on: app.db)
        let acronym2 = try Acronym.create(short: "OMG", long: "Oh My God", user: user, on: app.db)
        let acronym1 = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: app.db)
        
        try app.test(.GET, "\(acronymBaseURI)/sorted", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let sortedAcronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(sortedAcronyms.count, 2)
            XCTAssertEqual(sortedAcronyms[0].id, acronym1.id)
            XCTAssertEqual(sortedAcronyms[0].short, acronym1.short)
            XCTAssertEqual(sortedAcronyms[0].long, acronym1.long)
            
            XCTAssertEqual(sortedAcronyms[1].id, acronym2.id)
            XCTAssertEqual(sortedAcronyms[1].short, acronym2.short)
            XCTAssertEqual(sortedAcronyms[1].long, acronym2.long)
            
        })
    }
    
    func testGettingUserByAcronym() throws {
        let user = try User.create(on: app.db)
        let acronym = try Acronym.create(short: "OMG", long: "Oh My God", user: user, on: app.db)
        
        try app.test(.GET, "\(acronymBaseURI)/\(acronym.id!)/user", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let receivedUser = try response.content.decode(User.self)
            
            XCTAssertEqual(user.id, receivedUser.id)
            XCTAssertEqual(user.name, receivedUser.name)
            XCTAssertEqual(user.username, receivedUser.username)
        })
    }
    
    func testGettingAcronymBySearchTerm() throws {
        let searchTerm = "OMG"
        let user = try User.create(on: app.db)
        let acronym = try Acronym.create(short: searchTerm, long: "Oh My God", user: user, on: app.db)
        
        try app.test(.GET, "\(acronymBaseURI)/search?term=\(searchTerm)", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let searchableAcronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(searchableAcronyms[0].id, acronym.id)
            XCTAssertEqual(searchableAcronyms[0].short, acronym.short)
            XCTAssertEqual(searchableAcronyms[0].long, acronym.long)
        })
    }
    
    func testUpdatingExistingAcronym() throws {
        let user = try User.create(on: app.db)
        let acronym = try Acronym.create(short: "OMG", long: "Oh My God", user: user, on: app.db)
        
        let acronymToUpdate = CreateAcronymData(short: "LOL", long: "Laugh Out Loud", userID: user.id!)
        
        try app.test(.PUT, "\(acronymBaseURI)/\(acronym.id!)",
                     beforeRequest: { req in
                        try req.content.encode(acronymToUpdate)
                     }, afterResponse: { response in
                        XCTAssertEqual(response.status, .ok)
                        let updatedAcronym = try response.content.decode(Acronym.self)
                        
                        XCTAssertEqual(updatedAcronym.id, acronym.id)
                        XCTAssertEqual(updatedAcronym.short, acronymToUpdate.short)
                        XCTAssertEqual(updatedAcronym.long, acronymToUpdate.long)
                        
                        XCTAssertNotEqual(updatedAcronym.short, acronym.short)
                        XCTAssertNotEqual(updatedAcronym.long, acronym.long)
                     })
    }
    
    func testDeletingAcronym() throws {
        let user = try User.create(on: app.db)
        let acronym1 = try Acronym.create(short: "OMG", long: "Oh My God", user: user, on: app.db)
        
        try app.test(.GET, acronymBaseURI, afterResponse: { response in
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms.count, 1)
        })
        
        try app.test(.DELETE, "\(acronymBaseURI)/?id=\(acronym1.id!)", afterResponse: { response in
            XCTAssertEqual(response.status, .noContent)
        })
        
        try app.test(.GET, acronymBaseURI, afterResponse: { response in
          let newAcronyms = try response.content.decode([Acronym].self)
          XCTAssertEqual(newAcronyms.count, 0)
        })
    }
    
    func testAcronymsCategories() throws {
        let user = try User.create(on: app.db)
        let acronym = try Acronym.create(short: "OMG", long: "Oh My God", user: user, on: app.db)
        let category = try Category.create(name: "NewCat", on: app.db)
        let category2 = try Category.create(on: app.db)
        
        try app.test(.POST, "\(acronymBaseURI)/\(acronym.id!)/categories/\(category.id!)")
        try app.test(.POST, "\(acronymBaseURI)/\(acronym.id!)/categories/\(category2.id!)")
        
        
        try app.test(.GET, "\(acronymBaseURI)/\(acronym.id!)/categories", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let categories = try response.content.decode([App.Category].self)
            
            XCTAssertEqual(categories.count, 2)
            XCTAssertEqual(categories[0].name, category.name)
            XCTAssertEqual(categories[1].name, category2.name)
        })
        
        try app.test(.DELETE, "\(acronymBaseURI)/\(acronym.id!)/categories/\(category.id!)", afterResponse: { response in
            XCTAssertEqual(response.status, .noContent)
        })
        
        try app.test(.GET, "\(acronymBaseURI)/\(acronym.id!)/categories", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let categories = try response.content.decode([App.Category].self)
            
            XCTAssertEqual(categories.count, 1)
            XCTAssertEqual(categories[0].name, category2.name)
        })
    }
}
