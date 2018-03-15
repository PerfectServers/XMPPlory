//
//  IQRegister.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

public struct IQRegisterProcessor: XStanzaProcessor {
	public let registrations: [XStanzaProcessorRegistration] = [.init(localName: "query", uri: "jabber:iq:register", closedOnly: true)]
	public func processStanza(session: XSession, component: XStanzaComponent) throws {
		throw XSessionError("!FIX! Write me.")
	}
}
