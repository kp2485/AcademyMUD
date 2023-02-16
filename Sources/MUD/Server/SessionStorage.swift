//  Created by Kyle Peterson on 2/6/23.
//

import Foundation
import NIO

struct Session {
    let id: UUID
    let channel: Channel
    var playerID: UUID?
    var shouldClose = false
}

final class SessionStorage {
    static private var sessions = [Session]()
    static private var lock = NSLock()
    
    static func replaceOrStoreSessionSync(_ session: Session) {
        // Lock/unlock prevents values from being changed from another thread while the function is running. Swift arrays are not thread-safe by default.
        lock.lock()
        
        if let existingSessionIndex = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[existingSessionIndex] = session
        } else {
            sessions.append(session)
        }
        
        lock.unlock()
    }
    
    static func first(where predicate: (Session) throws -> Bool) -> Session? {
        lock.lock()
        let result = try? sessions.first(where: predicate)
        lock.unlock()
        return result
    }
    
    static func deleteSession(_ session: Session) {
        lock.lock()
        
        if let existingSessionIndex = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions.remove(at: existingSessionIndex)
            print("Successfully deleted session: \(session)")
        } else {
            print("Could not find session \(session)")
        }
    }
}
