//  Created by Kyle Peterson on 2/6/23.
//

import Foundation

struct Room: DBType {
    private static var allRooms: AcademyDB<Room> = AcademyDB()
    
    var id: UUID
    
    let name: String
    let description: String
    let exits: [Exit]
    
    var formattedDescription: String {
        """
        \(name)
        \(description)
        Exits: \(exits)
        """
    }
    
    static let starterRoomID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")
    
    var exitsAsString: String {
        let direction = exits.map { $0.direction.rawValue }
        return direction.joined(separator: " ")
    }
    
    static func find(_ id: UUID?) async -> Room? {
        if id == nil {
            return nil
        }
        
        return await allRooms.first(where: { $0.id == id })
    }
}

struct Exit: Codable {
    let direction: Direction
    let targetRoomID: UUID
}

enum Direction: String, Codable {
    case North
    case South
    case East
    case West
    case Up
    case Down
    case In
    case Out
    
    var opposite: Direction {
        switch self {
        case .North:
            return .South
        case .South:
            return .North
        case .East:
            return .West
        case .West:
            return .East
        case .Up:
            return .Down
        case .Down:
            return .Up
        case .In:
            return .Out
        case .Out:
            return .In
        }
    }
    
    public init?(stringValue: String) {
        let capitalizedStringValue = stringValue.capitalized
        self.init(rawValue: capitalizedStringValue)
    }
}
