//
//  IQ.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

// handles the initial iq stanza and dispatches to other processors
public struct IQStanzaProcessor: XStanzaProcessor {
	public let registrations: [XStanzaProcessorRegistration] = [.init(localName: "iq", uri: xmppClientNs, closedOnly: true)]
	public func processStanza(session: XSession, component: XStanzaComponent) throws {
		guard session.state == .serverStreamSent else {
			throw XSessionError("Invalid session state for this stanza.")
		}
		guard case .closedElement(let parent, let children) = component else {
			throw XSessionError("Unexpected element for this stanza \(component).")
		}
		guard let id = parent.attributes?.first(where: { $0.localName == "id" })?.value,
			let type = parent.attributes?.first(where: { $0.localName == "type" })?.value else {
				throw XSessionError("IQ stanza did not have \"id\" attribute.")
		}
		for child in children {
			switch child {
			case .startElement(_), .endElement(_):
				throw XSessionError("Unexpected element for this stanza \(child).")
			case .closedElement(let e, _):
				guard let proc = try? session.getProcessor(key: e.key) else {
					session.queueStanzas([StanzaOpen(name: "iq", attributes: [("id", id), ("type", "error")], empty: false),
										  StanzaOpen(name: "error", empty: false),
										  StanzaOpen(name: "text", attributes: [("xmlns", "urn:ietf:params:xml:ns:xmpp-stanzas")], empty: false),
										  "Unsupported",
										  StanzaClose(name: "text"),
										  StanzaClose(name: "error"),
										  StanzaClose(name: "iq")])
					return
				}
				try proc.processStanza(session: session, component: child)
			case .chars(_):
				()
			}
		}
	}
}
