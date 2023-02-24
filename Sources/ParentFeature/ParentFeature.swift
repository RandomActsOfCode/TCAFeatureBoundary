import ChildFeature
import ComposableArchitecture
import SwiftUI

// MARK: - Parent

public struct Parent: ReducerProtocol {
  // MARK: Public

  public struct State {
    // MARK: Lifecycle

    public init(child: Child.State = .init()) {
      self.child = child
    }

    // MARK: Public

    public var child: Child.State
  }

  public enum Action {
    case child(action: Child.Action)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce(core)
    Scope(state: \.child, action: /Action.child(action:)) {
      Child()
    }
  }

  // MARK: Private

  private func core(into state: inout State, action: Action) -> EffectTask<Action> {
    // No use of dependencies in core logic
    .none
  }
}

// MARK: - ParentView

public struct ParentView: View {
  // MARK: Lifecycle

  public init(store: StoreOf<Parent>) {
    self.store = store
  }

  // MARK: Public

  public var body: some View {
    VStack {
      Text("Parent view")
      ChildView(
        store: store.scope(
          state: \.child,
          action: Parent.Action.child
        )
      )
    }
  }

  // MARK: Private

  private let store: StoreOf<Parent>
}
