//  Created by Kyle Peterson on 2/5/23.
//

import Foundation
import NIO

struct VerbCommand {
    let session: Session
    let verb: Verb
}

final class VerbHandler: ChannelInboundHandler {
    
    typealias InboundIn = TextCommand
    typealias InboundOut = VerbCommand
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let textCommand = self.unwrapInboundIn(data)
        
        let verb = Verb.createVerb(from: textCommand.command)
        
        let verbCommand = VerbCommand(session: textCommand.session, verb: verb)
        
        context.fireChannelRead(wrapInboundOut(verbCommand))
    }
}
