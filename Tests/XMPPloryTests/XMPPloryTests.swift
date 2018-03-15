import XCTest
@testable import XMPPlory
import PerfectNet

class XMPPloryTests: XCTestCase {
	override func setUp() {
		super.setUp()
	}
	
	func testServerLaunch() {
		do {
			let x1 = expectation(description: "x1")
			let x2 = expectation(description: "x2")
			let server = try XServer(name: "localhost", processors: XServer.standardProcessors)
			DispatchQueue.global().async {
				x1.fulfill()
				do {
					try server.start()
				}  catch {
					XCTFail("\(error)")
				}
				x2.fulfill()
			}
			wait(for: [x1], timeout: 2)
			DispatchQueue.global().async {
				try! NetTCP().connect(address: "127.0.0.1", port: UInt16(xmppClientPort), timeoutSeconds: 3) {
					net in
					XCTAssertNotNil(net)
					server.close()
				}
			}
			wait(for: [x2], timeout: 2)
		} catch {
			XCTFail("\(error)")
		}
	}
	
	func testServerRun() {
		do {
			let server = try XServer(name: "127.0.0.1", processors: XServer.standardProcessors + [IQRegisterProcessor()])
			try server.start()
		} catch {
			XCTFail("\(error)")
		}
	}
	
	static let allTests: [(String, (XMPPloryTests) -> () throws -> Void)] = [
		("testServerLaunch", testServerLaunch)
	]
}
