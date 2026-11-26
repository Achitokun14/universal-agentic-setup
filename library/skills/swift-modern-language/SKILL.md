---
name: swift-modern-language
description: "Use when writing, reviewing or migrating Swift 6: concurrency errors, data races, hangs, retain cycles, tests"
---

# Modern Swift (language level)

Swift is progressive disclosure: start with the simplest, most static, most single-threaded thing that works, and buy dynamism (concurrency, reference semantics, existentials, unsafe pointers) only where you can state the reason. This skill is about the language and concurrency model, not SwiftUI view composition (out of scope here).

Toolchain baseline: Swift 6.3; check `swift --version`. Concurrency guidance assumes the Swift 6.2 model; on 6.1 or earlier the `async`/`@concurrent` rules differ. Items marked unreleased (6.4) are safe to plan for, not to write; prefer the older form unless the project's toolchain has them.

## Defaults (move down a row only with a stated reason)

| Need | Reach for | Move down when |
| --- | --- | --- |
| Data | `struct`/`enum`, `let` | identity, sharing or inheritance needed |
| Abstraction | concrete type | the same code repeats across types |
| Polymorphism | `some P` | heterogeneous storage needed -> `any P` |
| Execution | main actor, synchronous | profiling shows a hang -> `async` -> `@concurrent` -> `actor` |
| Memory | `Array`, `String` | profiling shows cost -> `InlineArray`, `Span` |
| Safety | safe API | C interop or measured hot path -> `Unsafe*` |

## Rules

1. Model with value types; enums for closed sets and mutually exclusive state (replace piles of optionals); a struct holding a mutable reference is neither value nor reference (copy-on-write or keep the reference immutable).
2. Recoverable failure -> `throw`; programmer mistake -> `precondition`/`fatalError`. `guard` for exits. Typed throws for internal/generic/constrained code; untyped `throws` for public API. Force-unwrap only with a statable invariant.
3. Single-threaded first. Concurrency has real cost; profile with Instruments before offloading; do the algorithmic fix first.
4. Turn on Approachable Concurrency in every project and main-actor default isolation for app/UI modules (not general-purpose libraries; libraries ship `nonisolated` APIs). With these on, a `nonisolated async` function runs on the caller's actor; use `@concurrent` only for your own CPU-heavy work.
5. Data race error ladder: (1) do not share it (give each job its own instance), (2) make it a `Sendable` value type, (3) isolate to an actor, (4) only then `Mutex`/`Atomic` or `@unchecked Sendable`. Most model classes should be neither `@MainActor` nor `Sendable`.
6. Structured concurrency (`async let`, task groups) over `Task {}`; `Task.detached` almost never; cancellation is cooperative; bound fan-out; `await` breaks atomicity and re-check state after it; actors give mutual exclusion, not transactions (mutate in synchronous methods; actors are not FIFO).
7. SwiftUI: actions are synchronous on purpose; start `withAnimation` in the callback and open a `Task` only for the long-running part; in `@Sendable` closures (`visualEffect`, `Shape.path`, `Layout`) capture the value you need, not `self`.
8. Protocols: concrete types first, protocol after repetition appears; protocol requirement = customization point (extension-only methods are statically dispatched and get shadowed); composition over inheritance; `some P` before `any P`.
9. Clarity at the point of use outranks everything in API design; access control is documentation; make illegal states unrepresentable.
10. Measure then choose: complexity first (`remove(at:)` in a loop is O(n^2)), then `final`, whole-module optimization, COW for large structs, homogeneous arrays over `[any P]`, `InlineArray`, `Span`.
11. `weak`/`unowned` break cycles only; prefer restructuring to a tree; never depend on when `deinit` runs.
12. Swift Testing (`@Test`, `#expect`, `#require`, parameterized `arguments:`) for new tests; XCTest only for UI automation, performance metrics, Objective-C.
13. `Logger` (os) not `print`; interpolations are private by default; log a correlation ID.
14. Prefer `Span` to `Unsafe*Pointer`; keep unsafe regions minimal with buffer pointers; run Address Sanitizer; enable strict memory safety in security-critical modules.
15. Migration to Swift 6: build with the new compiler in Swift 5 mode; per target enable complete concurrency checking starting at the UI layer; fix cheapest warnings first (global `var` to `let`, functions onto `@MainActor`, a public struct to `Sendable`); flip language mode; next target; refactor separately afterwards, never combined.

## Procedure

1. Read the project: toolchain, language mode, concurrency settings, test framework. Do not change build settings or toolchain without telling the user what and why.
2. For an error or hang, name the cause class (isolation, Sendable, reentrancy, blocking the main actor, cycle, complexity) and pick the fix from the ladders above rather than silencing the diagnostic.
3. Compile/test only on the user's request or when the task requires verification; report what ran.

## References

- `references/concurrency.md`: load for actors, reentrancy, Sendable, task groups, continuations, AsyncStream, SwiftUI isolation.
- `references/types-api-performance.md`: load for value types and COW, `some`/`any`, API design, performance levers, ARC and lifetimes.
- `references/testing-syntax-migration.md`: load for Swift Testing details, macros, logging, unsafe interop, modern-syntax replacements and the Swift 6 migration steps.
