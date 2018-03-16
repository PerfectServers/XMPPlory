//
//  IQDisco.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-15.
//

import Foundation

public struct IQDiscoProcessor: XStanzaProcessor {
	public init() {}
	public func registrations(session: XSession) -> [XStanzaProcessorRegistration] {
		return [.init(localName: "query", uri: "http://jabber.org/protocol/disco#info", closedOnly: true)]
	}
	public func streamFeatures(session: XSession) -> [XServerStanzaElement] {
		return []
	}
	public func processStanza(session: XSession, component: XClientStanzaComponent) throws {
		//throw XStreamError("!FIX! Write me.")
	}
}
