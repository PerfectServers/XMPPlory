//
//  Stanza.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-14.
//

import Foundation
import PerfectXML

public struct XClientStanzaElement {
	public let localName: String
	public let prefix: String?
	public let uri: String?
	public let namespaces: [SAXDelegateNamespace]?
	public let attributes: [SAXDelegateAttribute]?
	public let closed: Bool

	var key: String { return "\(localName) \(closed) \(uri ?? "")" }
	
	func isClose(localName: String, uri: String?) -> Bool {
		return !closed && localName == self.localName && uri == self.uri
	}
}

public enum XStanzaComponent {
	case startElement(XClientStanzaElement), endElement(XClientStanzaElement), closedElement(XClientStanzaElement, [XStanzaComponent]), chars(String)
}

public protocol StanzaElement {
	var bytes: [UInt8] { get }
}

extension String: StanzaElement {
	public var bytes: [UInt8] {
		return Array(self.utf8)
	}
}

struct StanzaOpen: StanzaElement {
	let name: String
	let attributes: [(String, String)]
	let empty: Bool
	init(name n: String, attributes a: [(String, String)] = [], empty e: Bool) {
		name = n
		attributes = a
		empty = e
	}
	var bytes: [UInt8] {
		let str = "<\(name)" + attributes.map { " \($0.0)=\"\($0.1)\"" }.joined(separator: "") + "\(empty ? "/" : "")>\n"
		return Array(str.utf8)
	}
}

struct StanzaClose: StanzaElement {
	let name: String
	var bytes: [UInt8] {
		return Array("</\(name)>\n".utf8)
	}
}
