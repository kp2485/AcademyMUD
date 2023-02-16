//  Created by Kyle Peterson on 2/5/23.
//

import Foundation
import NIO

struct TextCommand {
    let session: Session
    let command: String
}

final class SessionHandler: ChannelInboundHandler {
    
    typealias InboundIn = ByteBuffer
    typealias InboundOut = TextCommand
    
    // React to data coming in
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let inBuff = self.unwrapInboundIn(data)
        let str = inBuff.getString(at: 0, length: inBuff.readableBytes) ?? ""
        
        let session = SessionStorage.first(where: { $0.channel.remoteAddress == context.channel.remoteAddress }) ?? Session(id: UUID(), channel: context.channel, playerID: nil)
        
        SessionStorage.replaceOrStoreSessionSync(session)
        
        let command = TextCommand(session: session, command: str)
        
        context.fireChannelRead(wrapInboundOut(command))
    }
    
    // React to session being created
    public func channelActive(context: ChannelHandlerContext) {
        let welcomeText = """
        Welcome to AcademyMUD!
        Hope you enjoy your stay.
        Please use 'CREATE_USER <username> <password>' to begin.
        You can leave by using the 'CLOSE' command.
        """
        
        let greenString = "\u{1B}[32m" + welcomeText + "\u{1B}[0m" + "\n> "
        
        var outBuff = context.channel.allocator.buffer(capacity: greenString.count)
        outBuff.writeString(greenString)
        
        context.writeAndFlush(NIOAny(outBuff), promise: nil)
    }
}
