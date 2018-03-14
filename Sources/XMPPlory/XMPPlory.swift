//
//  XMPPlory.swift
//  XMPPlory
//
//  Created by Kyle Jessup on 2018-03-13.
//

import Foundation

/*
	access to user auth
	friends list
		msgs have biq as focus
	databases

*/

public struct XAddress {
	var username: String
	var domain: String
	var resource: String?
}

public protocol XRecipient {
	
}

public protocol XSender {
	
}

public struct XStream {
	public let id: UUID
	public let to: String
	public let from: String
	public let version: String
	public let lang: String
}
