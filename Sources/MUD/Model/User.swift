//
//  File.swift
//  
//
//  Created by Kyle Peterson on 2/6/23.
//

import Foundation

struct User: DBType {
    private static var allUsers: AcademyDB<User> = AcademyDB()
    
    let id: UUID
    let username: String
    let hashedPassword: String
    var currentRoomID: UUID?
    
    init(id: UUID? = nil, username: String, password: String) {
        self.id = id ?? UUID()
        self.username = username
        
        self.hashedPassword = Hasher.hash(password + username)
    }
    
    // Use a throwing function to check if user already exists with this username.
    static func create(username: String, password: String) async throws -> User {
        guard await User.first(username: username) == nil else {
            throw UserError.usernameAlreadyTaken
        }
        
        let player = User(id: UUID(), username: username, password: password)
        await player.save()
        return player
    }
    
    static func login(username: String, password: String) async throws -> User? {
        guard let user = await User.first(username: username) else {
            throw UserError.userNotFound
        }
        
        guard Hasher.verify(password: password + username, hashedPassword: user.hashedPassword) else {
            throw UserError.passwordMismatch
        }
        
        return user
    }
    
    static func first(username: String) async -> User? {
        await allUsers.first(where: { $0.username == username })
    }
    
    static func find(_ id: UUID?) async -> User? {
        if id == nil {
            return nil
        }
        
        return await allUsers.first(where: { $0.id == id })
    }
    
    func save() async {
        await Self.allUsers.replaceOrAddDatabaseObject(self)
        
        await Self.allUsers.save()
    }
    
    static func filter(where predicate: (User) -> Bool) async -> [User] {
        await Self.allUsers.filter(where: predicate)
    }
    
}

// Definition of possible user errors:
enum UserError: Error {
    case usernameAlreadyTaken
    case userNotFound
    case passwordMismatch
}



// let player = await User.find(id: playerID)

// static func find(id: UUID) async -> User?
