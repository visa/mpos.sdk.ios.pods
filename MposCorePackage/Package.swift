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
                    url: "https://artifactory.trusted.visa.com/mpos-staging/io/payworks/mpos.ios.sdk/2.55.0-20220909-4da8fbae6b/mpos.ios.sdk-2.55.0-20220909-4da8fbae6b.zip",
                    checksum: "aeb983e0247ad9f8d583400c103b51f7895a04feaddd1b270856e3702946cd85"
            ),
    ]
)

