//
//  Stream.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

public struct StreamStanzaProcessor: XStanzaProcessor {
	public func registrations(session: XSession) -> [XStanzaProcessorRegistration] {
		return [.init(localName: "stream", uri: xmppStreamsNs, closedOnly: false)]
	}
	public func streamFeatures(session: XSession) -> [XServerStanzaElement] {
		return []
	}
	public func processStanza(session: XSession, component: XClientStanzaComponent) throws {
		guard session.state == .new else {
			throw XStreamError("Invalid session state for this stanza.")
		}
		session.queueStanzas([xmlDocHead,
							  StanzaOpen(name: "stream:stream", attributes: [
								("xmlns:stream", xmppStreamsNs),
								("xmlns", xmppClientNs),
								("version", xmppStreamVersion),
								("id", session.id),
								("from", session.serverName)
								], empty: false)])
		let rest: [XServerStanzaElement] = [StanzaOpen(name: "stream:features", empty: false)] +
										session.streamFeatures +
										[StanzaClose(name: "stream:features")]
		session.queueStanzas(rest)
		session.state = .serverStreamSent
	}
}
