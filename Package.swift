// swift-tools-version:4.0
// Generated automatically by Perfect Assistant 2
// Date: 2018-03-14 12:51:48 +0000
import PackageDescription

let package = Package(
	name: "XMPPlory",
	products: [
		.library(name: "XMPPlory", targets: ["XMPPlory"])
	],
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-Net.git", from: "3.1.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-XML.git", from: "3.1.0"),
		.package(url: "https://github.com/kjessup/Perfect-SQLite.git", .branch("master"))
	],
	targets: [
		.target(name: "XMPPlory", dependencies: ["PerfectXML", "PerfectNet", "PerfectSQLite"]),
		.testTarget(name: "XMPPloryTests", dependencies: ["XMPPlory"])
	]
)
