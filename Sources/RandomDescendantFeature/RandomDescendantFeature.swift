import ComposableArchitecture
import Dependencies
import SwiftUI

// MARK: - RandomDescendant

public struct RandomDescendant: ReducerProtocol {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public struct State: Equatable {
    public init() {}
  }

  public enum Action {
    case onAppear
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce(core)
  }

  // MARK: Internal

  @Dependency(\.uuid)
  var uuid

  // MARK: Private

  private func core(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .onAppear:
      // Use of dependency locale
      print(uuid())
      return .none
    }
  }
}

// MARK: - RandomDescendantView

public struct RandomDescendantView: View {
  // MARK: Lifecycle

  public init(store: StoreOf<RandomDescendant>) {
    self.store = store
  }

  // MARK: Public

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Text("Random descendant view")
        .onAppear { viewStore.send(.onAppear) }
    }
  }

  // MARK: Private

  private let store: StoreOf<RandomDescendant>
}
