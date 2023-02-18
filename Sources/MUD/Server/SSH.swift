//
//  SSH.swift
//  
//
//  Created by Kyle Peterson on 2/18/23.
//

import Foundation
import NIO
import NIOSSH

enum SSHServerError: Error {
    case invalidCommand
    case invalidDataType
    case invalidChannelType
    case alreadyListening
    case notListening
}

final class ErrorHandler: ChannelInboundHandler {
    typealias InboundIn = Any
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error in pipeline: \(error)")
        context.close(promise: nil)
    }
}

final class NoLoginDelegate: NIOSSHServerUserAuthenticationDelegate {
    var supportedAuthenticationMethods: NIOSSHAvailableUserAuthenticationMethods {
        .all
    }
    
    func requestReceived(request: NIOSSHUserAuthenticationRequest, responsePromise: EventLoopPromise<NIOSSHUserAuthenticationOutcome>) {
        responsePromise.succeed(.success)
    }
}

final class MUDGlobalRequestDelegate: GlobalRequestDelegate {
    
}

func sshChildChannelInitializer(_ channel: Channel,_ channelType: SSHChannelType) -> EventLoopFuture<Void> {
    switch channelType {
    case .session:
        return channel.pipeline.addHandlers([BackPressureHandler(), SessionHandler(), VerbHandler(), ParseHandler(), ResponseHandler()])
    default:
        print("\(channelType) sessions are not supported. Only session channels are supported.")
        return channel.eventLoop.makeFailedFuture(SSHServerError.invalidChannelType)
    }
}
