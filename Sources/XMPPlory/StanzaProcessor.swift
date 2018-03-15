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
	var registrations: [XStanzaProcessorRegistration] { get }
	func processStanza(session: XSession, component: XStanzaComponent) throws
}
