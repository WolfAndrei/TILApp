import Fluent
import FluentPostgresDriver
import Vapor
import Leaf

// configures your application
// uncomment to serve files from /Public folder
// app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
public func configure(_ app: Application) throws {
    
    //website, working with static files
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let databaseName: String
    let databasePort: Int
    
    if app.environment == .testing {
        databaseName = "vapor-test"
        if let testPort = Environment.get("DATABASE_PORT") { //this branch was created for compatibility to Linux
            databasePort = Int(testPort) ?? 5433
        } else {
           databasePort = 5433
        }
    } else {
        databaseName = "vapor_database"
        databasePort = 5432
    }

    //MARK: - SQLite
    /*
     //import FluentSQLiteDriver
     
     app.databases.use(.sqlite(.memory), as: .sqlite)  --- for tests
     app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)  --- for work
    
     //if file doesn't exist - Fluent creates new one, otherwise Fluent uses the existing file.
     
     
     app.migrations.add(CreateAcronym())
     app.logger.logLevel = .debug
     try app.autoMigrate().wait()
     
     try routes(app)
    */
    
    //MARK: - MySQL
    
    /*
        import FluentMySQLDriver
        app.databases.use(.mysql(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database"
            tlsConfiguration: .forClient(certificateVersion: .none)
        ), as: .mysql)
     
        MySQL uses a TLS connection by default. When running in Docker, MySQL generates a self-signed certificate. Your application doesn’t know about this certificate. To allow your app to connect you need to disable certificate verification. You must not use this for a production application. You should provide the certificate to trust for a production application.

        app.migrations.add(CreateAcronym())
        app.logger.logLevel = .debug
        
        try app.autoMigrate().wait()
        
        // register routes
        try routes(app)
    */
    
    //MARK: - MongoDB
    
    /*
        import FluentMongoDriver
        app.databases.use(.mongo(
            connectionString: "mongodb://localhost:27017/vapor"),
        as: .mongo)

     
        app.migrations.add(CreateAcronym())
        app.logger.logLevel = .debug
        
        try app.autoMigrate().wait()
        
        // register routes
        try routes(app)
    */
    
    
    //MARK: - PostgreSQL
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: databasePort,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? databaseName
    ), as: .psql)
    //Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber
    
    //Order is important
    app.migrations.add(CreateUser())    // parent
    app.migrations.add(CreateAcronym()) // children
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateAcronymCategoryPivot()) // binding acronym && category for more efficiently quering on db
    /*
     for example,
     category might contain an array of acronyms
     and in its turn acronym might contain an array of categories
     
     "Slang"- [
            "Omg",
              |->["Slang", "Old-fashioned"]
            "LOL"
              |->["Slang"]
     ]
     */
    
    
    app.logger.logLevel = .debug
    
    //db config
    try app.autoMigrate().wait()
    
    //website config
    app.views.use(.leaf)
    
    // register routes
    try routes(app)
}



/*
 
 docker ps
 ps -- display currently running process
 
--name      - Assign a name to the container
 -e         - Set environment variables
 -p         - Publish a container's port(s) to the host (Allow applications to connect to the MySQL server on its default port)
 -d         - Run container in background and print container ID (Use the Docker image named mysql for this container. If the image is not           present on your machine, Docker automatically downloads it)

SQLite
     `nothing`
 
PotgreSQL
     docker run --name postgres \
     -e POSTGRES_DB=vapor_database \
     -e POSTGRES_USER=vapor_username \
     -e POSTGRES_PASSWORD=vapor_password \
     -p 5432:5432 \
     -d postgres

MySQL
     docker run --name mysql \
     -e MYSQL_USER=vapor_username \
     -e MYSQL_PASSWORD=vapor_password \
     -e MYSQL_DATABASE=vapor_database \
     -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
     -p 3306:3306 \
     -d mysql
 
 MongoDB
      docker run --name mongo \
      -e MONGO_INITDB_DATABASE=vapor \
      -p 27017:27017 \
      -d mongo
 */
