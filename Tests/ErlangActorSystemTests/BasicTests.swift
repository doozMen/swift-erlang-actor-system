import Testing
import Distributed
import Foundation
@testable import ErlangActorSystem

@Suite("Basic Tests", .serialized) struct BasicTests {
    @Test func connectActors() async throws {
        let cookie = UUID().uuidString
        
        let actorSystem1 = try await ErlangActorSystem(name: UUID().uuidString, cookie: cookie)
        let actorSystem2 = try await ErlangActorSystem(name: UUID().uuidString, cookie: cookie)
        try await actorSystem1.connect(to: actorSystem2.name)
        #expect(actorSystem1.remoteNodes.count == 1)
        #expect(actorSystem2.remoteNodes.count == 1)
    }
    
    @Test func remoteCall() async throws {
        distributed actor TestActor {
            typealias ActorSystem = ErlangActorSystem
            
            distributed func ping() -> String {
                return "pong"
            }
            
            distributed func greet(_ name: String) -> String {
                return "Hello, \(name)!"
            }
        }
        
        let cookie = UUID().uuidString
        
        let actorSystem1 = try await ErlangActorSystem(name: UUID().uuidString, cookie: cookie)
        let actorSystem2 = try await ErlangActorSystem(name: UUID().uuidString, cookie: cookie)
        try await actorSystem1.connect(to: actorSystem2.name)
        
        let actor = TestActor(actorSystem: actorSystem2)
        
        let remoteActor = try TestActor.resolve(id: actor.id, using: actorSystem1)
        
        await remoteActor.whenLocal { _ in
            #expect(Bool(false), "Remote actor should not be local")
        }
        
        #expect(try await remoteActor.ping() == "pong")
        #expect(try await remoteActor.greet("John Doe") == "Hello, John Doe!")
    }
    
    @Test func simpleStableNameRemoteCall() async throws {
        let cookie = UUID().uuidString
        
        let actorSystem1 = try await ErlangActorSystem(name: UUID().uuidString, cookie: cookie)
        let actorSystem2 = try await ErlangActorSystem(name: UUID().uuidString, cookie: cookie)
        try await actorSystem1.connect(to: actorSystem2.name)
        
        let actor = SimpleStableNameTestActor(actorSystem: actorSystem2)
        
        let remoteActor = try SimpleStableNameTestActor.resolve(id: actor.id, using: actorSystem1)
        
        await remoteActor.whenLocal { _ in
            #expect(Bool(false), "Remote actor should not be local")
        }
        
        var encoder = actorSystem1.makeInvocationEncoder()
        try encoder.doneRecording()
        #expect(try await actorSystem1.remoteCall(
            on: remoteActor,
            target: RemoteCallTarget("ping"),
            invocation: &encoder,
            throwing: (any Error).self,
            returning: String.self
        ) == "pong")
    }
}

// Define actors at module level to avoid local type issues
@StableNames
distributed actor SimpleStableNameTestActor {
    typealias ActorSystem = ErlangActorSystem
    
    @StableName("ping")
    distributed func ping() -> String {
        return "pong"
    }
    
    @StableName("hello")
    distributed func hello() -> String {
        return "world"
    }
}