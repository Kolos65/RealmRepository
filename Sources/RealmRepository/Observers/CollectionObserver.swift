//
//  CollectionObserver.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import RealmSwift

class CollectionObserver<Model: Object> {

    private var token: NotificationToken?
    private var onChange: (isolated RealmActor, Results<Model>) -> Void

    init(_ onChange: @escaping (isolated RealmActor, Results<Model>) -> Void) {
        self.onChange = onChange
    }

    @RealmActor
    func startObserving(_ results: Results<Model>) async {
        token = await results.observe(on: RealmActor.shared) { [weak self] actor, changes in
            switch changes {
            case .initial(let latest):
                self?.onChange(actor, latest)
            case .update(let latest, _, _, _):
                self?.onChange(actor, latest)
            default:
                return
            }
        }
    }

    func stopObserving() {
        token?.invalidate()
    }
}
