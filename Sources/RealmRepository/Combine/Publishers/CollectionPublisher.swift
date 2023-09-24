//
//  RepositoryCollectionPublisher.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Combine
import RealmSwift

struct CollectionPublisher<Model: Object>: Publisher where Model: Detachable {

    typealias Output = [Model]
    typealias Failure = Error
    typealias Observer = CollectionObserver<Model>

    final class CollectionSubscription: Subscription {
        private let observer: Observer
        init(observer: Observer) {
            self.observer = observer
        }
        func request(_ demand: Subscribers.Demand) {}
        func cancel() {
            observer.stopObserving()
        }
    }

    private let models: @RealmActor @Sendable () throws -> Results<Model>

    init(models: @RealmActor @Sendable @escaping () throws -> Results<Model>) {
        self.models = models
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, [Model] == S.Input {
        let observer = Observer { _, objects in
            _ = subscriber.receive(objects.asDetachedArray())
        }
        let subscription = CollectionSubscription(observer: observer)
        subscriber.receive(subscription: subscription)
        Task.detached { @RealmActor in
            do {
                let models = try self.models()
                await observer.startObserving(models)
            } catch {
                subscriber.receive(completion: .failure(error))
            }
        }
    }
}
