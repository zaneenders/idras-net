// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "indras-net",
  platforms: [.macOS(.v15)],
  dependencies: [
    .package(
      url: "https://github.com/swift-server/swift-kafka-client",
      branch: "main"),
    .package(
      url: "https://github.com/swift-server/swift-service-lifecycle.git",
      from: "2.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "Producer",
      dependencies: [
        .product(name: "Kafka", package: "swift-kafka-client"),
        .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
      ]
    ),
    .executableTarget(
      name: "Consumer",
      dependencies: [
        .product(name: "Kafka", package: "swift-kafka-client"),
        .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
      ]),
  ]
)
