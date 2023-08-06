//
//  ObjectObserver.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import RealmSwift

class ObjectObserver<Model: Object> {

    private var token: NotificationToken?
    private var onChange: (isolated RealmActor, Model?) -> Void

    init(_ onChange: @escaping (isolated RealmActor, Model?) -> Void) {
        self.onChange = onChange
    }

    @RealmActor
    func startObserving(_ result: Model) async {
        token = await result.observe(on: RealmActor.shared) { [weak self] actor, changes in
            switch changes {
            case .change:
                self?.onChange(actor, result)
            case .deleted:
                self?.onChange(actor, nil)
            default:
                return
            }
        }
    }

    func stopObserving() {
        token?.invalidate()
    }
}
