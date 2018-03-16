//
//  IQPrivate.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-15.
//

import Foundation

public struct IQPrivateProcessor: XStanzaProcessor {
	public init() {}
	public func registrations(session: XSession) -> [XStanzaProcessorRegistration] {
		return [.init(localName: "query", uri: "jabber:iq:private", closedOnly: true)]
	}
	public func streamFeatures(session: XSession) -> [XServerStanzaElement] {
		return []
	}
	public func processStanza(session: XSession, component: XClientStanzaComponent) throws {
		guard case .closedElement(let parent, let children) = component else {
			throw XStreamError("Unexpected element for this stanza \(component).")
		}
		guard let id = session.scratchPad[iqIdKey] as? String,
			let type = session.scratchPad[iqTypeKey] as? String else {
				throw XStreamError("IQ stanza did not have \"id\" or \"type\" attribute.")
		}
		for child in children {
			switch child {
			case .startElement(_), .endElement(_):
				throw XStreamError("Unexpected element for this stanza \(child).")
			case .closedElement(let e, _):
				guard let proc = try? session.getProcessor(key: e.key) else {
					return IQProcessor.iqError(session, id: id, text: "Unsupported")
				}
				try proc.processStanza(session: session, component: child)
			case .chars(_):
				()
			}
		}
		switch type {
		case "get":
			session.queueStanza(
				"""
				<iq id="\(id)" type="result">
				<query xmlns="jabber:iq:private"/>
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
