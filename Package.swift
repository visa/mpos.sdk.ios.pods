// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mpos_core",
    platforms: [
        .iOS(.v15)
       ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "mpos_core",
                 targets: ["mpos_core"]),
    ],
    targets: [
        .binaryTarget(
                    name: "mpos_core",
                    url:"https://repo.visa.com/mpos-releases/io/payworks/mpos.ios.sdk/2.55.0/mpos.ios.sdk-2.55.0.zip",
                    checksum: "16af7011f9f1db60a681cffe27a0e560d52d5e27edd16f7fa56980138930ffce"
            ),
    ]
)

