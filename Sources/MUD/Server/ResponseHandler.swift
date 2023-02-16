//  Created by Kyle Peterson on 2/5/23.
//

import Foundation
import NIO

final class ResponseHandler: ChannelInboundHandler {
    
    typealias InboundIn = [MudResponse]
    typealias InboundOut = ByteBuffer
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let responses = self.unwrapInboundIn(data)
        
        responses.forEach { response in
            let greenString = "\u{1B}[32m" + response.message + "\u{1B}[0m" + "\n> "
            
            var outBuff = context.channel.allocator.buffer(capacity: greenString.count)
            outBuff.writeString(greenString)
            
            response.session.channel.writeAndFlush(self.wrapInboundOut(outBuff), promise: nil)
            
            // Update the session, because we might have a player id or any other settings changed from commands
            SessionStorage.replaceOrStoreSessionSync(response.session)
            
            if response.session.shouldClose {
                print("Closing session: \(response.session)")
                SessionStorage.deleteSession(response.session)
                _ = context.close()
        }
        
        
        }
    }
}
