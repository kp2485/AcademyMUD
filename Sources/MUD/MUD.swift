import NIO
import Foundation
import NIOSSH

@main
public struct MUD {

    public static func main() {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        
        defer {
            try! group.syncShutdownGracefully()
        }
        
        let fixedKeyBase64 = "eRz2fTiZozlTa/oVdnFgp8+gWXedWTgHPXjg66nn0nA="
        let fixedKeyData = Data(base64Encoded: fixedKeyBase64)!
        let hostKey = NIOSSHPrivateKey(ed25519Key: try! .init(rawRepresentation: fixedKeyData))
        
        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
        
        
            .childChannelInitializer { channel in
                channel.pipeline.addHandlers([
                    NIOSSHHandler(role: .server(.init(hostKeys: [hostKey], userAuthDelegate: NoLoginDelegate(), globalRequestDelegate: MUDGlobalRequestDelegate() )), allocator: channel.allocator, inboundChildChannelInitializer: sshChildChannelInitializer(_:_:)), ErrorHandler()
                ])
            }
        
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)

        // MARK: Pipeline
        // BackPressureHandler (ByteBuffer) -> SessionHandler (TextCommand) -> VerbHandler (VerbCommand) -> ParseHandler (MudResponse) -> ResponseHandler (ByteBuffer)
        
//            .childChannelInitializer { channel in
//                channel.pipeline.addHandlers([BackPressureHandler(), SessionHandler(), VerbHandler(), ParseHandler(), ResponseHandler()])
//            }
//
//            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
//            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
//            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
        
        // Add default Enviornment value with PRODUCT >> SCHEME >> Edit Scheme...
        let host = ProcessInfo.processInfo.environment["ACADEMYMUD_HOSTNAME"] ?? "::1"
        let port = Int(ProcessInfo.processInfo.environment["ACADEMYMUD_PORT"] ?? "2121") ?? 2121
        
        let channel = try! bootstrap.bind(host: host, port: port).wait()
        
        print("Server started successfully, listening on address: \(channel.localAddress!)")
        
        try! channel.closeFuture.wait()
        
        print("Server closed")
    }
}
