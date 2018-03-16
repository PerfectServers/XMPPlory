//
//  IQAuth.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation

private let username = "username"
private let password = "password"

public protocol XAuthProvider {
	var supportsSha1: Bool { get }
	func isValidUsername(_ name: String) -> Bool
	func validatePasswordSha1(_ name: String, digestHex: String, resource: String) -> Bool
	func validatePassword(_ name: String, password: String, resource: String) -> Bool
}

public struct IQAuthProcessor<A: XAuthProvider>: XStanzaProcessor {
	let provider: A
	public init(provider p: A) {
		provider = p
	}
	public func registrations(session: XSession) -> [XStanzaProcessorRegistration] {
		return [.init(localName: "query", uri: "jabber:iq:auth", closedOnly: true)]
	}
	
	public func streamFeatures(session: XSession) -> [XServerStanzaElement] {
//				<mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
//					<mechanism>PLAIN</mechanism>
//				</mechanisms>
		return []
	}
	public func processStanza(session: XSession, component: XClientStanzaComponent) throws {
		guard session.state == .serverStreamSent else {
			throw XStreamError("Invalid session state for this stanza.")
		}
		guard case .closedElement(_, let children) = component else {
			throw XStreamError("Unexpected element for this stanza \(component).")
		}
		guard let id = session.scratchPad[iqIdKey] as? String,
				let type = session.scratchPad[iqTypeKey] as? String else {
			throw XStreamError("IQ stanza did not have \"id\" or \"type\" attribute.")
		}
		switch type {
		case "get":
			var supports: [XServerStanzaElement] = [StanzaOpen(name: "username", empty: true),
							StanzaOpen(name: "resource", empty: true)]
			if provider.supportsSha1 {
				supports += [StanzaOpen(name: "digest", empty: true)]
			} else {
				supports += [StanzaOpen(name: "password", empty: true)]
			}
			session.queueStanzas([
					StanzaOpen(name: "iq", attributes: [("type", "result"), ("id", id)], empty: false),
					StanzaOpen(name: "query", attributes: [("xmlns", "jabber:iq:auth")], empty: false)])
			session.queueStanzas(supports)
			session.queueStanzas([
					StanzaClose(name: "query"),
					StanzaClose(name: "iq")])
		case "set":
			var u: String?
			var d: String?
			var r: String?
			var p: String?
			for child in children {
				switch child {
				case .startElement(_), .endElement(_):
					throw XStreamError("Unexpected element for this stanza \(child).")
				case .closedElement(let e, let c):
					switch e.localName {
					case "username":
						u = c.allText
					case "digest":
						d = c.allText
					case "resource":
						r = c.allText
					case "password":
						p = c.allText
					default:
						() // ignore
					}
				case .chars(_):
					()
				}
			}
			let valid: Bool
			if provider.supportsSha1 {
				guard let username = u, let digest = d, let resource = r else {
					return IQProcessor.iqError(session, id: id, text: "Invalid response")
				}
				valid = provider.validatePasswordSha1(username, digestHex: digest, resource: resource)
			} else {
				guard let username = u, let password = p, let resource = r else {
					return IQProcessor.iqError(session, id: id, text: "Invalid response")
				}
				valid = provider.validatePassword(username, password: password, resource: resource)
			}
			if valid {
				session.queueStanza(StanzaOpen(name: "iq", attributes: [("type", "result"), ("id", id)], empty: true))
			} else {
				session.queueStanzas([StanzaOpen(name: "iq", attributes: [("id", id), ("type", "error")], empty: false),
									  StanzaOpen(name: "error", attributes: [("code", "401"), ("type", "quth")], empty: false),
									  StanzaOpen(name: "not-authorized", attributes: [("xmlns", "urn:ietf:params:xml:ns:xmpp-stanzas")], empty: true),
									  StanzaClose(name: "error"),
									  StanzaClose(name: "iq")])
			}
		default:
			IQProcessor.iqError(session, id: id, text: "Invalid type attribute")
		}
	}
}




