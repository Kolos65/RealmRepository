//
//  UserDataModel.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
import RealmSwift

class UserDataModel: Object {
    @Persisted(primaryKey: true)
    var id = UUID()

    @Persisted var name: String = ""
    @Persisted var age: Int = 0
    @Persisted var email: String = ""

    var asDomainModel: User {
        User(id: id, name: name, age: age, email: email)
    }
}

extension User {
    var asDataModel: UserDataModel {
        let model = UserDataModel()
        model.id = id
        model.name = name
        model.age = age
        model.email = email
        return model
    }
}
