//
//  UserTests.swift
//  
//
//  Created by Andrei Volkau on 15.06.2021.
//

@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    
    let usersName = "Alice"
    let usersUsername = "alice"
    
    let baseUserURI = "/api/users"
    var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testUsersCanBeRetrievedFromAPI() throws {
        
        /// This function saves a user, created with the supplied details, in the database.
        let user = try User.create(name: usersName, username: usersUsername, on: app.db)
        let _ = try User.create(on: app.db)
        
        /// That method give us opportunity to test the particular api request !!! Correct String value is IMPORTANT!
        try app.test(.GET, "\(baseUserURI)/all/", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let users = try response.content.decode([User].self)
            
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0].name, usersName)
            XCTAssertEqual(users[0].username, usersUsername)
            XCTAssertEqual(users[0].id, user.id)
        })
    }
    
    func testUserCanBeSavedWithAPI() throws {
        
        let user = User(name: usersName, username: usersUsername)
        
        try app.test(.POST, baseUserURI,
                     beforeRequest: { req in
                        try req.content.encode(user)
                     },
                     afterResponse: { response in
                        XCTAssertEqual(response.status, .ok)
                        let receivedUser = try response.content.decode(User.self)
                        XCTAssertEqual(receivedUser.name, user.name)
                        XCTAssertEqual(receivedUser.username, user.username)
                        XCTAssertNotNil(receivedUser.id)
                        
                        try app.test(.GET, "\(baseUserURI)/all/", afterResponse: { secResponse in
                            XCTAssertEqual(secResponse.status, .ok)
                            let users = try secResponse.content.decode([User].self)
                            
                            XCTAssertEqual(users.count, 1)
                            XCTAssertEqual(users[0].name, user.name)
                            XCTAssertEqual(users[0].username, user.username)
                            XCTAssertEqual(users[0].id, receivedUser.id)
                        })
                     })
    }
    
    
    func testGettingASingleUserFromAPI() throws {
        let user = try User.create(name: usersName, username: usersUsername, on: app.db)
        try app.test(.GET, "\(baseUserURI)/?id=\(user.id!)", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let receivedUser = try response.content.decode(User.self)
            
            XCTAssertEqual(receivedUser.name, usersName)
            XCTAssertEqual(receivedUser.username, usersUsername)
            XCTAssertEqual(receivedUser.id, user.id)
        })
    }
    
    func testGettingAUsersAcronymsFromAPI() throws {
        let user = try User.create(on: app.db)
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        
        let acronym1 = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: app.db)
        let _ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: app.db)
        
        try app.test(.GET, "\(baseUserURI)/\(user.id!)/acronyms/", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let receivedAcronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(receivedAcronyms.count, 2)
            XCTAssertEqual(receivedAcronyms[0].id, acronym1.id)
            XCTAssertEqual(receivedAcronyms[0].short, acronym1.short)
            XCTAssertEqual(receivedAcronyms[0].long, acronym1.long)
        })
    }
}
