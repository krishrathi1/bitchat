import Foundation
import CoreBluetooth
import Testing
@testable import bitchat

struct BLEConnectTimeoutPolicyTests {
    @Test
    func validConnectingAttemptTriggersTimeout() {
        let token: UInt64 = 42
        
        // When state is nil -> false
        #expect(!BLEConnectTimeoutPolicy.shouldExecuteConnectTimeout(
            capturedAttemptToken: token,
            state: nil,
            isPeripheralConnected: false
        ))
    }

    @Test
    func supersededAttemptTokenIgnoresTimeout() {
        let capturedToken: UInt64 = 1
        let currentToken: UInt64 = 2

        let mockState = BLEPeripheralLinkState(
            peripheral: CBPeripheralMock.create(),
            characteristic: nil,
            isConnecting: true,
            isConnected: false,
            lastConnectionAttempt: Date(),
            attemptToken: currentToken,
            assembler: NotificationStreamAssembler()
        )

        let result = BLEConnectTimeoutPolicy.shouldExecuteConnectTimeout(
            capturedAttemptToken: capturedToken,
            state: mockState,
            isPeripheralConnected: false
        )

        #expect(!result)
    }

    @Test
    func matchingAttemptTokenExecutesTimeout() {
        let token: UInt64 = 5

        let mockState = BLEPeripheralLinkState(
            peripheral: CBPeripheralMock.create(),
            characteristic: nil,
            isConnecting: true,
            isConnected: false,
            lastConnectionAttempt: Date(),
            attemptToken: token,
            assembler: NotificationStreamAssembler()
        )

        let result = BLEConnectTimeoutPolicy.shouldExecuteConnectTimeout(
            capturedAttemptToken: token,
            state: mockState,
            isPeripheralConnected: false
        )

        #expect(result)
    }

    @Test
    func connectedStateIgnoresTimeout() {
        let token: UInt64 = 5

        let mockState = BLEPeripheralLinkState(
            peripheral: CBPeripheralMock.create(),
            characteristic: nil,
            isConnecting: false,
            isConnected: true,
            lastConnectionAttempt: Date(),
            attemptToken: token,
            assembler: NotificationStreamAssembler()
        )

        let result = BLEConnectTimeoutPolicy.shouldExecuteConnectTimeout(
            capturedAttemptToken: token,
            state: mockState,
            isPeripheralConnected: true
        )

        #expect(!result)
    }
}

// Helper mock CBPeripheral for tests
private final class CBPeripheralMock {
    static func create() -> CBPeripheral {
        let dummy = UnsafeMutableRawPointer.allocate(byteCount: 256, alignment: 16)
        dummy.initializeMemory(as: UInt8.self, repeating: 0)
        return Unmanaged<CBPeripheral>.fromOpaque(dummy).takeUnretainedValue()
    }
}
