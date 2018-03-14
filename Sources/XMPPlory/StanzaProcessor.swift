//
//  StanzaProcessor.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

public struct XStanzaProcessorRegistration {
	let localName: String
	let uri: String
	let closedOnly: Bool
	public init(localName l: String, uri u: String, closedOnly c: Bool = true) {
		localName = l
		uri = u
		closedOnly = c
	}
}

public protocol XStanzaProcessor {
	var registrations: [XStanzaProcessorRegistration] { get }
	func processStanza(session: XSession, component: XStanzaComponent) throws
}

struct StreamStanzaProcessor: XStanzaProcessor {
	let registrations: [XStanzaProcessorRegistration] = [.init(localName: "stream", uri: xmppStreamsNs, closedOnly: false)]
	func processStanza(session: XSession, component: XStanzaComponent) throws {
		guard session.state == .new else {
			throw XSessionError("Invalid session state for this stanza.")
		}
		session.queueStanza(xmlDocHead)
		session.queueStanza(StanzaOpen(name: "stream:stream", attributes: [
			("xmlns:stream", xmppStreamsNs),
			("xmlns", xmppClientNs),
			("version", xmppStreamVersion),
			("id", session.id),
			("from", session.serverName),
			], empty: false))
		session.queueStanza(StanzaOpen(name: "stream:features", empty: false))
		//...
		session.queueStanza(StanzaClose(name: "stream:features"))
		session.state = .serverStreamSent
	}
}

struct IQStanzaProcessor: XStanzaProcessor {
	let registrations: [XStanzaProcessorRegistration] = [.init(localName: "iq", uri: xmppClientNs, closedOnly: true)]
	
	func processStanza(session: XSession, component: XStanzaComponent) throws {
		guard session.state == .serverStreamSent else {
			throw XSessionError("Invalid session state for this stanza.")
		}
		guard case .closedElement(let parent, let children) = component else {
			throw XSessionError("Unexpected element for this stanza \(component).")
		}
		guard let id = parent.attributes?.first(where: { $0.localName == "id" }) else {
			throw XSessionError("IQ did not have \"id\" attribute.")
		}
		for child in children {
			switch child {
			case .startElement(_), .endElement(_):
				throw XSessionError("Unexpected element for this stanza \(child).")
			case .closedElement(let e, _):
				guard let proc = try? session.getProcessor(key: e.key) else {
					throw XSessionError("Unexpected element for this stanza \(component).")
				}
				try proc.processStanza(session: session, component: child)
			case .chars(_):
				()
			}
		}
	}
}




