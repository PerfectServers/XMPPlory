//
//  Presence.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

public struct PresenceProcessor: XStanzaProcessor {
	public let registrations: [XStanzaProcessorRegistration] = [.init(localName: "presence", uri: xmppClientNs, closedOnly: true)]
	public func processStanza(session: XSession, component: XStanzaComponent) throws {
		guard session.state == .serverStreamSent else {
			throw XSessionError("Invalid session state for this stanza.")
		}
		guard case .closedElement(let parent, let children) = component else {
			throw XSessionError("Unexpected element for this stanza \(component).")
		}
		throw XSessionError("!FIX! Write me.")
	}
}
