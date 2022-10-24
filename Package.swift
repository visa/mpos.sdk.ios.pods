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
                    url:"https://artifactory.trusted.visa.com:443/mpos-staging/io/payworks/mpos.ios.sdk/2.56.0-20221020-c41f2a1c4a/mpos.ios.sdk-2.56.0-20221020-c41f2a1c4a.zip",
                    checksum: "0584dcab1ecd459260ba9c7e81fd0db553f073150edb0a780ad74fedc679d43f"
            ),
    ]
)

