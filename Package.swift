// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "TcaFeatureBoundary",
  platforms: [.iOS(.v15), .macOS(.v13)],
  products: [
    .library(
      name: "ParentFeature",
      targets: ["ParentFeature"]
    ),
    .library(
      name: "ChildFeature",
      targets: ["ChildFeature"]
    ),
    .library(
      name: "RandomDescendantFeature",
      targets: ["RandomDescendantFeature"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      from: "0.50.1"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies",
      from: "0.1.4"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
      from: "1.10.0"
    ),
  ],
  targets: [
    .target(
      name: "ParentFeature",
      dependencies: [
        "ChildFeature",
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(
          name: "Dependencies",
          package: "swift-dependencies"
        ),
      ]
    ),
    .testTarget(
      name: "ParentFeatureTests",
      dependencies: [
        "ParentFeature",
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(
          name: "SnapshotTesting",
          package: "swift-snapshot-testing"
        ),
      ]
    ),
    .target(
      name: "ChildFeature",
      dependencies: [
        "RandomDescendantFeature",
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(
          name: "Dependencies",
          package: "swift-dependencies"
        ),
      ]
    ),
    .target(
      name: "RandomDescendantFeature",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(
          name: "Dependencies",
          package: "swift-dependencies"
        ),
      ]
    ),
  ]
)
