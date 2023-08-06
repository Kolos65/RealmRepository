//
//  AnyAsyncSequence.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
public struct AnyAsyncSequence<Element>: AsyncSequence {

    // MARK: Initializers

    /// Create an `AnyAsyncSequence` from an `AsyncSequence` conforming type
    /// - Parameter sequence: The `AnySequence` type you wish to erase
    public init<T: AsyncSequence>(_ sequence: T) where T.Element == Element {
        makeAsyncIteratorClosure = { AnyAsyncIterator(sequence.makeAsyncIterator()) }
    }

    // MARK: API

    public struct AnyAsyncIterator: AsyncIteratorProtocol {
        private let nextClosure: () async throws -> Element?

        public init<T: AsyncIteratorProtocol>(_ iterator: T) where T.Element == Element {
            var iterator = iterator
            nextClosure = { try await iterator.next() }
        }

        public func next() async throws -> Element? {
            try await nextClosure()
        }
    }

    // MARK: AsyncSequence

    public typealias Element = Element

    public typealias AsyncIterator = AnyAsyncIterator

    public func makeAsyncIterator() -> AsyncIterator {
        AnyAsyncIterator(makeAsyncIteratorClosure())
    }

    private let makeAsyncIteratorClosure: () -> AsyncIterator
}

extension AsyncSequence {
    /// Create a type erased version of this sequence
    /// - Returns: The sequence, wrapped in an `AnyAsyncSequence`
    public func eraseToAnyAsyncSequence() -> AnyAsyncSequence<Element> {
        AnyAsyncSequence(self)
    }
}
