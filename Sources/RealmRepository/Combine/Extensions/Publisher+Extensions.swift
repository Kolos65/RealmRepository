//
//  Publisher+Extensions.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Combine

extension Publisher {
    func shareReplay() -> AnyPublisher<Output, Failure> {
        map { Optional($0) }
        .multicast { CurrentValueSubject(nil) }
        .autoconnect()
        .compactMap { $0 }
        .eraseToAnyPublisher()
    }
}
