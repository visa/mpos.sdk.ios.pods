// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mpos_core",
    platforms: [
        .iOS(.v13)
       ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "mpos_core",
                 targets: ["mpos_core"]),
    ],
    targets: [
        .binaryTarget(
                    name: "mpos_core",
                    url: "https://repo.visa.com/mpos-releases/io/payworks/mpos.ios.sdk/2.54.0/mpos.ios.sdk-2.54.0.zip",
                    checksum: "87bd9a0c78a772216e129ed78f52ff8ad6cfc3cd2626a6dd961a97a236f168f2"
            ),
    ]
)

