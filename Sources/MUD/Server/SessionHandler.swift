//  Created by Kyle Peterson on 2/5/23.
//

import Foundation
import NIO
import NIOSSH

struct TextCommand {
    let session: Session
    let command: String
}

final class SessionHandler: ChannelInboundHandler {
    
    typealias InboundIn = SSHChannelData
    typealias InboundOut = TextCommand
    typealias OutboundOut = SSHChannelData
    
    // React to data coming in
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let inBuff = self.unwrapInboundIn(data)
        
        guard case .byteBuffer(let bytes) = inBuff.data else {
            fatalError("Unexpected read type")
        }
        
        guard case .channel = inBuff.type else {
            context.fireErrorCaught(SSHServerError.invalidDataType)
            return
        }
        
        let str = String(buffer: bytes)
        
        var session = SessionStorage.first(where: { $0.channel.remoteAddress == context.channel.remoteAddress }) ?? Session(id: UUID(), channel: context.channel, playerID: nil)
        
        session.currentString += str
        
        if str.contains("\n") || str.contains("\r") {
            let command = TextCommand(session: session.erasingCurrentString(), command: session.currentString)
            context.fireChannelRead(wrapInboundOut(command))
        } else {
            context.writeAndFlush(self.wrapOutboundOut(inBuff), promise: nil)
        }
        
        SessionStorage.replaceOrStoreSessionSync(session)
        
        
    }
    
    // React to session being created
    public func channelActive(context: ChannelHandlerContext) {
        let welcomeText = """
        Welcome to AcademyMUD!
        Hope you enjoy your stay.
        Please use 'CREATE_USER <username> <password>' to begin.
        You can leave by using the 'CLOSE' command.
        """
        
        let sshWelcomeText = welcomeText.replacingOccurrences(of: "\n", with: "\r\n")
        
        let greenString = "\u{1B}[32m" + sshWelcomeText + "\u{1B}[0m" + "\n\r> "
        
        var outBuff = context.channel.allocator.buffer(capacity: greenString.count)
        outBuff.writeString(greenString)
        
        let channelData = SSHChannelData(byteBuffer: outBuff)
        
        context.writeAndFlush(self.wrapOutboundOut(channelData), promise: nil)
    }
}

extension SSHChannelData {
    init(byteBuffer: ByteBuffer) {
        let ioData = IOData.byteBuffer(byteBuffer)
        self.init(type: .channel, data: ioData)
    }
}
