//
//  Server.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-13.
//

import Foundation
import Dispatch
import PerfectNet
import PerfectXML
import PerfectCRUD
import PerfectSQLite

public let xmppClientPort = 5222
public let xmppServerPort = 5269

private let databaseName = "file::memory:?cache=shared"
private typealias DB = Database<SQLiteDatabaseConfiguration>
private func getDB() throws -> DB {
	return Database(configuration: try SQLiteDatabaseConfiguration(databaseName))
}

public struct XServer {
	public static let standardProcessors: [XStanzaProcessor] = [StreamStanzaProcessor(),
																IQStanzaProcessor()]
	
	let name: String
	let net: NetTCP
	let processors: [XStanzaProcessor]
	public init(name n: String,
				processors p: [XStanzaProcessor],
				port: Int = xmppClientPort,
				address: String = "0.0.0.0") throws {
		name = n
		processors = p
		net = NetTCP()
		try net.bind(port: UInt16(port), address: address)
		print("Server bound on \(address):\(port)")
	}
	private func debug(msg: String) {
		print(msg)
	}
	
	public func start() throws {
		net.listen()
		net.forEachAccept {
			client in
			guard let client = client else {
				return
			}
			do {
				try self.accepted(client: client)
			} catch {
				self.handleError(error)
			}
		}
	}
	
	public func close() {
		// !FIX! graceful close connections
		do {
//			<stream:error>
//			<system-shutdown
//			xmlns='urn:ietf:params:xml:ns:xmpp-streams'/>
//			</stream:error>
//			</stream:stream>
		} catch {
			handleError(error)
		}
		
		net.close()
	}
	
	func handleError(_ error: Error) {
		debug(msg: "\(error)")
	}
	
	func accepted(client: NetTCP) throws {
		let session = XSession(client, serverName: name, processors: processors)
		try session.checkState()
	}
}
















