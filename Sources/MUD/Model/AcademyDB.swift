//
//  File.swift
//  
//
//  Created by Kyle Peterson on 2/6/23.
//

import Foundation

protocol DBType: Codable {
    var id: UUID { get }
}

actor AcademyDB<DatabaseType: DBType> {
    
    // type: User, filename: users.json
    // type: Room, filename: rooms.json
    
    static private var filename: String {
        dbName + ".json"
    }
    
    static private var dbName: String {
        "\(DatabaseType.self)".lowercased() + "s"
    }
    
    // All database types are loaded are initialized into the following storage variable.
    private var storage: [DatabaseType] = AcademyDB.loadStorage()

    private static func loadStorage() -> [DatabaseType] {
        
        // If file exists,
        if FileManager.default.fileExists(atPath: filename) {
            // create data object and
            if let data = FileManager.default.contents(atPath: filename) {
                do {
                    let decoder = JSONDecoder()
                    // try to return decoded data,
                    return try decoder.decode([DatabaseType].self, from: data)
                // handling errors with the below actions.
                } catch {
                    print("Error reading data: \(error).")
                }
            }
        // If file doesn't exist,
        } else {
            print("File: \(filename) not found.")
        }
        // return empty array.
        return []
    }
    
    func save() async {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            // Transform the storage into data,
            let data = try encoder.encode(storage)
            // get needed URL
            let url = URL(fileURLWithPath: Self.filename)
            // and try to write data to it,
            try data.write(to: url)
            print("Saved data to file: \(url)")
        // handling errors with the below actions.
        } catch {
            print("Error writing data: \(error).")
        }
    }
    
    func replaceOrAddDatabaseObject(_ databaseObject: DatabaseType) async {
        if let existingObjectIndex = storage.firstIndex(where: { $0.id == databaseObject.id } ) {
            storage[existingObjectIndex] = databaseObject
        } else {
            storage.append(databaseObject)
        }
    }
    
    func first(where predicate: (DatabaseType) throws -> Bool) async -> DatabaseType? {
        try? storage.first(where: predicate)
    }
    
    func filter(where predicate: (DatabaseType) throws -> Bool) async -> [DatabaseType] {
        (try? storage.filter(predicate)) ?? []
    }
}
