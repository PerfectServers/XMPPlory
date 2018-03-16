//
//  Config.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-13.
//

import Foundation
import PerfectNet

extension Date {
	static var now: TimeInterval {
		return Date().timeIntervalSince1970
	}
}

let xmlDocHead = "<?xml version=\"1.0\"?>\n"
let xmppStreamsNs = "http://etherx.jabber.org/streams"
let xmppClientNs = "jabber:client"
let xmppStreamVersion = "1.0"

let serverPrivateKeyPath = "/Users/kjessup/development/PerfectNeu/XMPPlory/config/server.key"
let serverCertPath = "/Users/kjessup/development/PerfectNeu/XMPPlory/config/server.crt"

