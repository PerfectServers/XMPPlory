//
//  IQ.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

public let iqIdKey = "iq:id"
public let iqTypeKey = "iq:type"

// handles the initial iq stanza and dispatches to other processors
public struct IQProcessor: XStanzaProcessor {
	public init() {}
	public static func iqError(_ session: XSession, id: String, text: String) {
		session.queueStanzas([StanzaOpen(name: "iq", attributes: [("id", id), ("type", "error")], empty: false),
							  StanzaOpen(name: "error", empty: false),
							  StanzaOpen(name: "text", attributes: [("xmlns", "urn:ietf:params:xml:ns:xmpp-stanzas")], empty: false),
							  text,
							  StanzaClose(name: "text"),
							  StanzaClose(name: "error"),
							  StanzaClose(name: "iq")])
	}
	public func registrations(session: XSession) -> [XStanzaProcessorRegistration] {
		return [.init(localName: "iq", uri: xmppClientNs, closedOnly: true)]
	}
	
	public func streamFeatures(session: XSession) -> [XServerStanzaElement] {
		return []
	}
	public func processStanza(session: XSession, component: XClientStanzaComponent) throws {
		guard session.state == .serverStreamSent else {
			throw XStreamError("Invalid session state for this stanza.")
		}
		guard case .closedElement(let parent, let children) = component else {
			throw XStreamError("Unexpected element for this stanza \(component).")
		}
		guard let id = parent.attributes?.first(where: { $0.localName == "id" })?.value,
			let type = parent.attributes?.first(where: { $0.localName == "type" })?.value else {
				throw XStreamError("IQ stanza did not have \"id\" or \"type\" attribute.")
		}
		session.scratchPad[iqIdKey] = id
		session.scratchPad[iqTypeKey] = type
		defer {
			session.scratchPad.removeValue(forKey: iqIdKey)
			session.scratchPad.removeValue(forKey: iqTypeKey)
		}
		for child in children {
			switch child {
			case .startElement(_), .endElement(_):
				throw XStreamError("Unexpected element for this stanza \(child).")
			case .closedElement(let e, _):
				guard let proc = try? session.getProcessor(key: e.key) else {
					return IQProcessor.iqError(session, id: id, text: "Unsupported")
				}
				try proc.processStanza(session: session, component: child)
			case .chars(_):
				()
			}
		}
	}
}
