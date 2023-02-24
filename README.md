# TCA Feature Boundary with Dependencies

## Setup

- A feature hierarchy where different features use different dependencies:

- The example hierarchy is 3 deep, but the `RandomDescendantFeature` is
illustrative of an arbitrarily deeply nested feature reachable from the
`ParentFeature`

```text
┌───────────────────────┐                                                     
│                       │                                                     
│    Parent Feature     │                          .─────────────.            
│                       │                      _.─'               `──.        
└───────────┬───────────┘                   ,─'                       '─.     
            │                             ,'                             `.   
       << uses >>                        ╱       Dependency Storage        ╲  
            │                           ╱                                   ╲ 
            ▼                          ;           ┌──────────┐              :
┌───────────────────────┐            ┌─┼───────────▶  Locale  │              │
│                       │            │ │           └──────────┘              │
│     Child Feature     ├─<< uses >>─┘ :                                     ;
│                       │               ╲          ┌──────────┐             ╱ 
└───────────┬───────────┘            ┌───╳────────▶│   UUID   │            ╱  
            │                        │    ╲        └──────────┘           ╱   
       << uses >>                    │     `.                           ,'    
            │                        │       '─.                     ,─'      
            ▼                        │          `──.             _.─'         
┌───────────────────────┐            │              `───────────'             
│   Random Descendant   │            │                                        
│        Feature        << uses >>───┘                                        
│                       │                                                     
└───────────────────────┘                                                     
```

## Problem

- A test is added to the `Parent` feature, and it immediately fails with a
cryptic message about `Locale` not being set. The parent feature does not use
`Locale`, and there is no indication that the `Child` feature does either
**without inspecting** it's implementation

- To fix this, the `Parent` feature test is updated to set `Locale`. Now the
test fails with an error about `uuid` not being implemented. To chase this one
down, the implementation of `Child` feature's reducer is examined, and we see
that it uses `RandomDescendantFeature`. In turn, the **implementation** of
`RandomDescendantFeature`'s reducer is examined, and a dependency to `uuid` is
found

- In the final attempt, a value for the `uuid` dependency is set from the
`Parent` feature's test fixture and the test final passes

  - What value should the parent provide for the descendant feature's
  dependencies? If written by a different developer / team, or if involving a
  different domain the appropriate value to use may not be obvious

  - If a far removed descendant feature is updated in the future with an
  additional dependency, the our test breaks again and we have to patch (along
  with any tests on the chain)

## Details

- In a testing context, all dependencies should have a default value of
`unimplemented` which traps if used by the system under test. This forces
developers to explicitly declare preconditions on their dependencies within
their tests by setting values when needed (a desirable attribute)

- With the new `Dependency` framework, dependencies are now considered an
**implementation detail** since they do not appear on the API of the feature
boundary (i.e. they can be added and removed without requiring updates by
consuming code)

- However, a TCA unit test is actually an integration test since a feature's
reducer is a composition of **concrete reducer types** which can not be mocked

- Therefore, if **any logic of a descendant feature on the feature hierarchy is
executed as part of a test** regardless of which feature the test belongs to,
it's dependencies must be explicitly set

## Thoughts

- Logic of a child reducer typically does not run as part of a standard
reducer test fixture so most fixtures won't encounter this issue

- One exception is when a reducer emits a descendant action into the `Store`
(either synchronously or asynchronously) to force the descendant reducer to run.
This does happen, but is rare and here we have no choice but manually
maintaining other feature's dependencies in the ancestor's test fixture

- Another exception is in `View` tests where the actual reducer is provided
rather than the `EmptyReducer`. This scenario can usually be avoided with some
up front feature design so that the real reducer is not needed for the `View`
test (i.e. the `View` test care only about `State`). However, this can't be
avoided in a end-to-end acceptance test since reducer logic must execute. Here,
we could bootstrap the fixture with a fully set environment (i.e. all
dependencies would be present)

- We might be able to create a wrapper reducer in a testing context that
swallows any action not belonging to the system under test. If so, this could
hardened the unit tests and avoid the issue altogether
