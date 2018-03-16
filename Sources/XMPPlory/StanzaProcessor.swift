//
//  StanzaProcessor.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

public struct XStanzaProcessorRegistration {
	let localName: String
	let uri: String
	let closedOnly: Bool
	public init(localName l: String, uri u: String, closedOnly c: Bool = true) {
		localName = l
		uri = u
		closedOnly = c
	}
}

public protocol XStanzaProcessor {
	func registrations(session: XSession) -> [XStanzaProcessorRegistration]
	func streamFeatures(session: XSession) -> [XServerStanzaElement]
	func processStanza(session: XSession, component: XClientStanzaComponent) throws
}
