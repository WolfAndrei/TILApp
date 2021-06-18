//
//  CategoriesTest.swift
//  
//
//  Created by Andrei Volkau on 17.06.2021.
//

@testable import App
import XCTVapor

class CategoriesTest: XCTestCase {
    
    var app: Application!
    let baseCategoryURI = "/api/categories"
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testGettingAllCategories() throws {
        let firstCat = try Category.create(name: "TestCat", on: app.db)
        let _ = try Category.create(on: app.db)
        
        try app.test(.GET, baseCategoryURI, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let allCategories = try response.content.decode([App.Category].self)
            
            XCTAssertEqual(allCategories.count, 2)
            XCTAssertEqual(allCategories[0].id, firstCat.id)
            XCTAssertEqual(allCategories[0].name, firstCat.name)
        })
    }
    
    func testGetCategoryById() throws {
        let firstCat = try Category.create(name: "TestCat", on: app.db)
        
        try app.test(.GET, "\(baseCategoryURI)/\(firstCat.id!)", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let receivedCat = try response.content.decode(App.Category.self)
            
            XCTAssertEqual(receivedCat.id, firstCat.id)
            XCTAssertEqual(receivedCat.name, firstCat.name)
        })
    }
    
    func testCreateNewCategory() throws {
        let category = App.Category(name: "NewTestCat")
        
        try app.test(.POST, "\(baseCategoryURI)/",
                     beforeRequest: { req in
                        try req.content.encode(category)
                     },
                     afterResponse: { response in
                        XCTAssertEqual(response.status, .ok)
                        let receivedCat = try response.content.decode(App.Category.self)
                        
                        XCTAssertNotNil(receivedCat.id)
                        XCTAssertEqual(receivedCat.name, category.name)
                        
                        try app.test(.GET, baseCategoryURI, afterResponse: { secResponse in
                            XCTAssertEqual(secResponse.status, .ok)
                            let allCategories = try secResponse.content.decode([App.Category].self)
                            
                            XCTAssertEqual(allCategories.count, 1)
                            XCTAssertEqual(allCategories[0].id, receivedCat.id)
                            XCTAssertEqual(allCategories[0].name, category.name)
                        })
                     })
    }
    
    func testGetAllAcronymsByCategoryId() throws {
        let acronym = try Acronym.create(short: "LOL", long: "Laugh Out Loud", on: app.db)
        let category = try Category.create(name: "TestCat", on: app.db)
        try app.test(.POST, "/api/acronyms/\(acronym.id!)/categories/\(category.id!)")
        
        try app.test(.GET, "\(baseCategoryURI)/\(category.id!)/acronyms", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let allAcronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(allAcronyms.count, 1)
            XCTAssertEqual(allAcronyms[0].id, acronym.id)
            XCTAssertEqual(allAcronyms[0].short, acronym.short)
            XCTAssertEqual(allAcronyms[0].long, acronym.long)
        })
    }
}
