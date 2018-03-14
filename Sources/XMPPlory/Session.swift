//
//  Session.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation
import Dispatch
import PerfectNet
import PerfectXML

let maxWriteSize = 1024 * 16

public struct XSessionError: Error {
	public let description: String
	public init(_ d: String) {
		description = d
	}
}

class XSAXDelegate: SAXDelegate {
	var saxItems: [XStanzaComponent] = []
	func startElementNs(localName: String,
						prefix: String?,
						uri: String?,
						namespaces: [SAXDelegateNamespace],
						attributes: [SAXDelegateAttribute]) {
		saxItems.append(.startElement(.init(localName: localName,
											prefix: prefix,
											uri: uri,
											namespaces: namespaces,
											attributes: attributes,
											closed: false)))
	}
	func endElementNs(localName: String,
					  prefix: String?,
					  uri: String?) {
		var i = (saxItems.endIndex-1)
		while i >= saxItems.startIndex {
			let item = saxItems[i]
			guard case .startElement(let e) = item else {
				i -= 1
				continue
			}
			if e.isClose(localName: localName, uri: uri) {
				let newE = XClientStanzaElement(localName: e.localName, prefix: e.prefix, uri: e.uri, namespaces: e.namespaces, attributes: e.attributes, closed: true)
				saxItems[i] = .closedElement(newE, Array(saxItems[i.advanced(by: 1)..<saxItems.endIndex]))
				saxItems = Array(saxItems[saxItems.startIndex...i])
				return
			}
			i -= 1
		}
		let closeElement = XClientStanzaElement(localName: localName, prefix: prefix, uri: uri, namespaces: [], attributes: [], closed: false)
		saxItems.append(.endElement(closeElement))
	}
	func characters(_ c: String) {
		saxItems.append(.chars(c))
	}
	func ignorableWhitespace(_ c: String) {
		print(#function)
	}
	func cdataBlock(_ c: String) {
		saxItems.append(.chars(c))
	}
}

public class XSession {
	public enum State: Int {
		case new, closed, serverStreamSent
	}
	let net: NetTCP
	let processors: [String:XStanzaProcessor]
	public let serverName: String
	public let id = UUID().uuidString
	let sax: SAXParser
	let saxDelegate = XSAXDelegate()
	public let startedAt: TimeInterval
	public let pingedAt: TimeInterval
	public var state: State = .new
	var writeStanzas: [StanzaElement] = []
	init(_ n: NetTCP, serverName s: String, processors p: [XStanzaProcessor]) {
		net = n
		serverName = s
		processors = Dictionary(uniqueKeysWithValues: p.flatMap {
			proc in
			return proc.registrations.map {
				reg in
				return ("\(reg.localName) \(reg.closedOnly) \(reg.uri)", proc)
			}
		})
		sax = SAXParser(delegate: saxDelegate)
		startedAt = Date.now
		pingedAt = 0
	}
	private func debug(msg: String) {
		print(msg)
	}
	public func getProcessor(key: String) throws -> XStanzaProcessor {
		guard let proc = processors[key] else {
			throw XSessionError("No processor for stanza \(key)")
		}
		return proc
	}
	
	func checkState() throws {
		guard state != .closed else {
			return debug(msg: "XSession closed.")
		}
		guard writeStanzas.isEmpty else {
			return try writePendingStanzas()
		}
		guard let top = saxDelegate.saxItems.first else {
			return buffer()
		}
		saxDelegate.saxItems.removeFirst()
		switch top {
		case .startElement(let e):
			try getProcessor(key: e.key).processStanza(session: self, component: top)
		case .endElement(let e):
			try getProcessor(key: e.key).processStanza(session: self, component: top)
		case .closedElement(let e, _):
			try getProcessor(key: e.key).processStanza(session: self, component: top)
		case .chars(_):
			()
		}
		try checkState()
	}
	
	public func queueStanza(_ s: StanzaElement) {
		writeStanzas.append(s)
	}
	
	func writePendingStanzas() throws {
		var bytes: [UInt8] = []
		while let item = writeStanzas.first {
			let b = item.bytes
			if bytes.count + b.count > maxWriteSize {
				break
			}
			bytes.append(contentsOf: b)
			writeStanzas.removeFirst()
		}
		debug(msg: "writing: \(String(describing: String(validatingUTF8: bytes)))")
		net.write(bytes: bytes) {
			wrote in
			do {
				guard wrote == bytes.count else {
					throw XSessionError("Unable to write bytes to client.")
				}
				try self.checkState()
			} catch {
				self.handleError(error)
			}
		}
	}
	
	func buffer() {
		net.readSomeBytes(count: 4096) {
			bytes in
			do {
				if let bytes = bytes, !bytes.isEmpty {
					self.debug(msg: "read: \(String(describing: String(validatingUTF8: bytes)))")
					try self.sax.pushData(bytes)
					try self.checkState()
				} else {
					self.bufferWait()
				}
			} catch {
				self.handleError(error)
			}
		}
	}
	
	func bufferWait() {
		net.readBytesFully(count: 1, timeoutSeconds: 5) {
			bytes in
			do {
				if let bytes = bytes {
					self.debug(msg: "read: \(String(describing: String(validatingUTF8: bytes)))")
					try self.sax.pushData(bytes)
					try self.checkState()
				} else {
					try self.idle()
				}
			} catch {
				self.handleError(error)
			}
		}
	}
	
	func idle() throws {
		// write me
		try checkState()
	}
	
	func handleError(_ error: Error) {
		switch state {
		case .new:
			debug(msg: "New session received error. Closing.")
			net.close()
		default:
			debug(msg: "\(error)")
		}
	}
}


