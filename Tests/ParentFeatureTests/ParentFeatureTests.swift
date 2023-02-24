import ComposableArchitecture
import SnapshotTesting
import XCTest

@testable import ParentFeature

final class ParentFeatureTests: XCTestCase {
  // First Attempt:
  // - This test fails since the dependency `locale` used by the Child feature is not implemented
  func testFirstTry() {
    assertSnapshot(
      matching: ParentView(
        store: .init(
          initialState: .init(),
          reducer: Parent()
        )
      ),
      as: .image
    )
  }

  // Second Attempt:
  // - Okay, let's set the `locale` even though it is a private implementation detail of Child ...
  // - Now it fails since `uuid` is accessed from the RandomDescendant feature and it is not implemented
  func testSecondTry() {
    assertSnapshot(
      matching: ParentView(
        store: .init(
          initialState: .init(),
          reducer: Parent()
        ) {
          // Try setting the missing dependency
          $0.locale = .autoupdatingCurrent
        }
      ),
      as: .image
    )
  }

  // Third Attempt:
  // - Final try: let's set the `uuid` even though it is a private implementation detail of a far away descendant
  //   feature
  // - Success? Yes, but only until a random, deeply nested feature decides to add a new dependency 😿
  func testThirdTry() {
    assertSnapshot(
      matching: ParentView(
        store: .init(
          initialState: .init(),
          reducer: Parent()
        ) {
          // Try setting ALL missing dependencies on the feature chain from Parent to RandomDescendant
          $0.locale = .autoupdatingCurrent
          $0.uuid = .init { .init() }
        }
      ),
      as: .image
    )
  }
}
