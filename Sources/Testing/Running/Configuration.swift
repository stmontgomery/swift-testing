//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors
//

/// A type containing settings for preparing and running tests.
@_spi(ExperimentalTestRunning)
public struct Configuration: Sendable {
  /// Initialize an instance of this type representing the default
  /// configuration.
  public init() {}

  /// Whether or not to parallelize the execution of tests and test cases (by
  /// default.)
  static var isParallelizationEnabledByDefault: Bool { Environment.flag(named: "SWT_ENABLE_PARALLELIZATION") ?? true }

  /// Whether or not to parallelize the execution of tests and test cases.
  public var isParallelizationEnabled = Self.isParallelizationEnabledByDefault

#if !SWT_NO_GLOBAL_ACTORS
  /// Whether or not synchronous test functions need to run on the main actor
  /// (by default.)
  ///
  /// This property is available on platforms where UI testing is implemented.
  static var isMainActorIsolationEnforcedByDefault: Bool { Environment.flag(named: "SWT_MAIN_ACTOR_ISOLATED") ?? false }

  /// Whether or not synchronous test functions need to run on the main actor.
  ///
  /// This property is available on platforms where UI testing is implemented.
  public var isMainActorIsolationEnforced = Self.isMainActorIsolationEnforcedByDefault
#endif

  // MARK: - Time limits

  /// Storage for the ``defaultTestTimeLimit`` property.
  private var _defaultTestTimeLimit: (any Sendable)? = {
    guard #available(_clockAPI, *) else {
      return nil
    }
    return Environment.variable(named: "SWT_DEFAULT_TEST_TIME_LIMIT_NANOSECONDS")
      .flatMap(UInt64.init)
      .map(Duration.nanoseconds)
  }()

  /// The default amount of time a test may run for before timing out if it does
  /// not have an instance of ``TimeLimitTrait`` applied to it.
  ///
  /// If the value of this property is `nil`, individual test functions may run
  /// up to the limit specified by ``maximumTestTimeLimit``.
  ///
  /// To determine the actual time limit that applies to an instance of
  /// ``Test`` at runtime, use ``Test/adjustedTimeLimit(configuration:)``.
  @available(_clockAPI, *)
  public var defaultTestTimeLimit: Duration? {
    get {
      _defaultTestTimeLimit as? Duration
    }
    set {
      _defaultTestTimeLimit = newValue
    }
  }

  /// Storage for the ``maximumTestTimeLimit`` property.
  private var _maximumTestTimeLimit: (any Sendable)? = {
    guard #available(_clockAPI, *) else {
      return nil
    }
    return Environment.variable(named: "SWT_MAXIMUM_TEST_TIME_LIMIT_NANOSECONDS")
      .flatMap(UInt64.init)
      .map(Duration.nanoseconds)
  }()

  /// The maximum amount of time a test may run for before timing out,
  /// regardless of the value of ``defaultTestTimeLimit`` or individual
  /// instances of ``TimeLimitTrait`` applied to it.
  ///
  /// If the value of this property is `nil`, individual test functions may run
  /// indefinitely.
  ///
  /// To determine the actual time limit that applies to an instance of
  /// ``Test`` at runtime, use ``Test/adjustedTimeLimit(configuration:)``.
  @available(_clockAPI, *)
  public var maximumTestTimeLimit: Duration? {
    get {
      _maximumTestTimeLimit as? Duration
    }
    set {
      _maximumTestTimeLimit = newValue
    }
  }

  /// Storage for the ``testTimeLimitGranularity`` property.
  private var _testTimeLimitGranularity: (any Sendable)? = {
    guard #available(_clockAPI, *) else {
      return nil
    }
    return Environment.variable(named: "SWT_TEST_TIME_LIMIT_GRANULARITY_NANOSECONDS")
      .flatMap(UInt64.init)
      .map(Duration.nanoseconds)
  }()

  /// The granularity to enforce on test time limits.
  ///
  /// By default, test time limit granularity is limited to intervals of one
  /// minute (60 seconds.) If finer or coarser granularity is required, the
  /// value of this property can be adjusted.
  @available(_clockAPI, *)
  public var testTimeLimitGranularity: Duration {
    get {
      (_testTimeLimitGranularity as? Duration) ?? .seconds(60)
    }
    set {
      _testTimeLimitGranularity = newValue
    }
  }

  // MARK: - Event handling

  /// Whether or not events of the kind
  /// ``Event/Kind-swift.enum/expectationChecked(_:)`` should be delivered to
  /// this configuration's ``eventHandler`` closure.
  ///
  /// By default, events of this kind are not delivered to event handlers
  /// because they occur frequently in a typical test run and can generate
  /// significant backpressure on the event handler.
  @_spi(ExperimentalEventHandling)
  public var deliverExpectationCheckedEvents = false

  /// The event handler to which events should be passed when they occur.
  @_spi(ExperimentalEventHandling)
  public var eventHandler: Event.Handler = { _, _ in }

  // MARK: - Test selection

  // TODO: Write DocC documenting this typealias.
  //
  // (Note: this typealias may also be used to eventually implement a similar
  // filter property for **skipped** tests. But that doesn't need to be
  // mentioned in the DocC.)
  public typealias TestPredicate = @Sendable (Test) -> Bool

  // TODO: Choose better name for this property.
  //
  // TODO: Write DocC documenting this property, explaining its purpose and
  // potentially including an example of its most common usage patterns.
  public var testSelectionFilter: TestPredicate?
}
