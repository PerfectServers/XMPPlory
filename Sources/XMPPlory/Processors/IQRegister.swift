//
//  IQRegister.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

public protocol XRegistrationProvider {
	
}

public struct IQRegisterProcessor<A: XRegistrationProvider>: XStanzaProcessor {
	public init() {}
	public func registrations(session: XSession) -> [XStanzaProcessorRegistration] {
		return [.init(localName: "query", uri: "jabber:iq:register", closedOnly: true)]
	}
	public func streamFeatures(session: XSession) -> [XServerStanzaElement] {
		return []
	}
	public func processStanza(session: XSession, component: XClientStanzaComponent) throws {
		throw XStreamError("!FIX! Write me.")
	}
}
