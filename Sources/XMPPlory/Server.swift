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

public struct XServerError: Error {
	public let description: String
	public init(_ d: String) {
		description = d
	}
}

public struct XServer {
	public static let standardProcessors: [XStanzaProcessor] = [StreamStanzaProcessor(),
																IQProcessor(),
																IQRosterProcessor(),
																IQPrivacyProcessor(),
																IQPrivateProcessor(),
																IQDiscoProcessor(),
																TLSProcessor(),
																MessageProcessor(),
																PresenceProcessor()]
	
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
		net.close()
		do {
			// !FIX! graceful close connections
//			<stream:error>
//			<system-shutdown
//			xmlns='urn:ietf:params:xml:ns:xmpp-streams'/>
//			</stream:error>
//			</stream:stream>
		} catch {
			handleError(error)
		}
	}
	
	func handleError(_ error: Error) {
		debug(msg: "\(error)")
	}
	
	func accepted(client: NetTCP) throws {
		let net = NetTCPSSL()
		net.fd = client.fd
		client.fd = .init(fd: invalidSocket) // so it doesn't close
		_ = net.setDefaultVerifyPaths()
		guard net.useCertificateFile(cert: serverCertPath),
			net.usePrivateKeyFile(cert: serverPrivateKeyPath),
			net.checkPrivateKey() else {
				let code = Int32(net.errorCode())
				throw XServerError("Error validating private key file: \(net.errorStr(forCode: code))")
		}
		let session = XSession(net, serverName: name, processors: processors)
		try session.checkState()
	}
}


