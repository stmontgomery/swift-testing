//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors
//

/// A type representing a custom display name applied to a test.
public struct DisplayNameTrait: Sendable {
  /// The display name contained in this instance.
  ///
  /// To obtain the display name applied to a test (if any), see
  /// ``Test/displayName``.
  public var displayName: String
}

// MARK: - Trait, TestTrait, SuiteTrait

extension DisplayNameTrait: TestTrait, SuiteTrait {}

// MARK: -

extension Test {
  /// The customized display name of this instance, if specified.
  public var displayName: String? {
    traits.lazy
      .compactMap { $0 as? DisplayNameTrait }
      .first?
      .displayName
  }
}
