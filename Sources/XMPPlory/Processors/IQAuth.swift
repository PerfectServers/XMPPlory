//
//  IQAuth.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

public struct IQAuthProcessor: XStanzaProcessor {
	public let registrations: [XStanzaProcessorRegistration] = [.init(localName: "query", uri: "jabber:iq:auth", closedOnly: true)]
	public func processStanza(session: XSession, component: XStanzaComponent) throws {
		throw XSessionError("!FIX! Write me.")
	}
}