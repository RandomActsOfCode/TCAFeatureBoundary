import ComposableArchitecture
import Dependencies
import RandomDescendantFeature
import SwiftUI

// MARK: - Child

public struct Child: ReducerProtocol {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public struct State: Equatable {
    // MARK: Lifecycle

    public init(randomDescendant: RandomDescendant.State = .init()) {
      self.randomDescendant = randomDescendant
    }

    // MARK: Public

    public var randomDescendant: RandomDescendant.State
  }

  public enum Action {
    case onAppear
    case randomDescendant(action: RandomDescendant.Action)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce(core)
    Scope(state: \.randomDescendant, action: /Action.randomDescendant) {
      RandomDescendant()
    }
  }

  // MARK: Internal

  @Dependency(\.locale)
  var locale

  // MARK: Private

  private func core(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .onAppear:
      // Use of dependency locale
      print(locale)
      return .none
    case .randomDescendant:
      return .none
    }
  }
}

// MARK: - ChildView

public struct ChildView: View {
  // MARK: Lifecycle

  public init(store: StoreOf<Child>) {
    self.store = store
  }

  // MARK: Public

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Text("Child view")
        RandomDescendantView(
          store: store.scope(
            state: \.randomDescendant,
            action: Child.Action.randomDescendant
          )
        )
      }
      .onAppear { viewStore.send(.onAppear) }
    }
  }

  // MARK: Private

  private let store: StoreOf<Child>
}
