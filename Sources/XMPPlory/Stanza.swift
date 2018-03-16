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

public enum XClientStanzaComponent {
	case startElement(XClientStanzaElement),
		endElement(XClientStanzaElement),
		closedElement(XClientStanzaElement, [XClientStanzaComponent]),
		chars(String)
}

extension Array where Element == XClientStanzaComponent {
	var allText: String {
		return self.flatMap {
			guard case .chars(let c) = $0 else {
				return nil
			}
			return c
		}.joined(separator: "")
	}
}

public protocol XServerStanzaElement {
	var bytes: [UInt8] { get }
}

extension String: XServerStanzaElement {
	public var bytes: [UInt8] {
		return Array(self.utf8)
	}
}

public struct StanzaOpen: XServerStanzaElement {
	let name: String
	let attributes: [(String, String)]
	let empty: Bool
	public init(name n: String, attributes a: [(String, String)] = [], empty e: Bool) {
		name = n
		attributes = a
		empty = e
	}
	public var bytes: [UInt8] {
		let str = "<\(name)" + attributes.map { " \($0.0)=\"\($0.1)\"" }.joined(separator: "") + "\(empty ? "/" : "")>\n"
		return Array(str.utf8)
	}
}

public struct StanzaClose: XServerStanzaElement {
	let name: String
	public init(name n: String) {
		name = n
	}
	public var bytes: [UInt8] {
		return Array("</\(name)>\n".utf8)
	}
}
