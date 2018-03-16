//
//  Message.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

public struct MessageProcessor: XStanzaProcessor {
	public init() {}
	public func registrations(session: XSession) -> [XStanzaProcessorRegistration] {
		return [.init(localName: "message", uri: xmppClientNs, closedOnly: true)]
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
		//throw XStreamError("!FIX! Write me.")
	}
}
