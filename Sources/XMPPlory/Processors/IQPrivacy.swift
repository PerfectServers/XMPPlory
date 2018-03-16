//
//  IQPrivacy.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-15.
//

import Foundation

public struct IQPrivacyProcessor: XStanzaProcessor {
	public init() {}
	public func registrations(session: XSession) -> [XStanzaProcessorRegistration] {
		return [.init(localName: "query", uri: "jabber:iq:privacy", closedOnly: true)]
	}
	public func streamFeatures(session: XSession) -> [XServerStanzaElement] {
		return []
	}
	public func processStanza(session: XSession, component: XClientStanzaComponent) throws {
		guard let id = session.scratchPad[iqIdKey] as? String,
			let type = session.scratchPad[iqTypeKey] as? String else {
				throw XStreamError("IQ stanza did not have \"id\" or \"type\" attribute.")
		}
		switch type {
		case "get":
			session.queueStanza(
				"""
				<iq id="\(id)" type="result">
				<query xmlns="jabber:iq:privacy">
				<default name="public"/>
				<list name="public"/>
				</query>
				</iq>
				
				"""
			)
		case "set":
			()
		default:
			IQProcessor.iqError(session, id: id, text: "Invalid type attribute")
		}
	}
}
