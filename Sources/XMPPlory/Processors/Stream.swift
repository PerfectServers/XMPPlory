//
//  Stream.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

public struct StreamStanzaProcessor: XStanzaProcessor {
	public let registrations: [XStanzaProcessorRegistration] = [.init(localName: "stream", uri: xmppStreamsNs, closedOnly: false)]
	public func processStanza(session: XSession, component: XStanzaComponent) throws {
		guard session.state == .new else {
			throw XSessionError("Invalid session state for this stanza.")
		}
		session.queueStanzas([xmlDocHead,
							  StanzaOpen(name: "stream:stream", attributes: [
								("xmlns:stream", xmppStreamsNs),
								("xmlns", xmppClientNs),
								("version", xmppStreamVersion),
								("id", session.id),
								("from", session.serverName),
								], empty: false),
							  StanzaOpen(name: "stream:features", empty: false),
							  StanzaClose(name: "stream:features")])
		// !FIX! send out features gathered from processors
		session.state = .serverStreamSent
	}
}
