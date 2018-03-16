//
//  TLS.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-15.
//

import Foundation
import PerfectNet

public struct TLSProcessor: XStanzaProcessor {
	public init() {
		_ = NetTCPSSL()
	}
	public func registrations(session: XSession) -> [XStanzaProcessorRegistration] {
		return [.init(localName: "starttls",
					  uri: "urn:ietf:params:xml:ns:xmpp-tls",
					  closedOnly: true)]
	}
	public func streamFeatures(session: XSession) -> [XServerStanzaElement] {
		guard !session.net.usingSSL else {
			return []
		}
		return ["<starttls xmlns=\"urn:ietf:params:xml:ns:xmpp-tls\"><required/></starttls>"]
	}
	public func processStanza(session: XSession, component: XClientStanzaComponent) throws {
		session.queueStanza("<proceed xmlns=\"urn:ietf:params:xml:ns:xmpp-tls\"/>")
		session.callbacks.append {
			done in
			session.net.setAcceptState()
			session.net.beginSSL {
				ok in
				if !ok {
					let code = session.net.errorCode()
					let msg = session.net.errorStr(forCode: Int32(code))
					let error = XStreamError("Error initiating TLS \(code) \(msg)")
					session.handleError(error)
				}
				session.restartStream()
				done()
			}
		}
	}
}
