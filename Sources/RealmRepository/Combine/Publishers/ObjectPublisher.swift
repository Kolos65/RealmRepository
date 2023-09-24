//
//  ObjectPublisher.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Combine
import RealmSwift

struct ObjectPublisher<Model: Object>: Publisher where Model: Detachable {

    typealias Output = Model
    typealias Failure = Error
    typealias Observer = ObjectObserver<Model>

    final class ObjectSubscription: Subscription {
        private let observer: Observer
        init(observer: Observer) {
            self.observer = observer
        }
        func request(_ demand: Subscribers.Demand) {}
        func cancel() {
            observer.stopObserving()
        }
    }

    private let model: @RealmActor @Sendable () throws -> Model?

    init(model: @RealmActor @Sendable @escaping () throws -> Model?) {
        self.model = model
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Model == S.Input {
        let observer = Observer { _, model in
            guard let model else {
                let error = RepositoryError.objectNotFound
                subscriber.receive(completion: .failure(error))
                return
            }
            _ = subscriber.receive(model.detached())
        }
        let subscription = ObjectSubscription(observer: observer)
        subscriber.receive(subscription: subscription)
        Task.detached { @RealmActor in
            do {
                guard let model = try self.model() else {
                    throw RepositoryError.keyNotFound
                }
                _ = subscriber.receive(model.detached())
                await observer.startObserving(model)
            } catch {
                subscriber.receive(completion: .failure(error))
            }
        }
    }
}
