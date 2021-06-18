//
//  Application+Testable.swift
//  
//
//  Created by Andrei Volkau on 17.06.2021.
//

import XCTVapor
import App

extension Application {
    /// This function creates app with testable environment and configures it.
    static func testable() throws -> Application {
        let app = Application(.testing)
        try configure(app)
        
        try app.autoRevert().wait()
        try app.autoMigrate().wait()
        
        return app
    }
}
