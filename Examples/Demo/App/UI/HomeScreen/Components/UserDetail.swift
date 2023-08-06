//
//  UserDetail.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import SwiftUI

struct UserDetail: View {

    // MARK: Properties

    var user: User
    var update: (UUID, String) -> Void

    // MARK: Private Properties

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""

    // MARK: UI

    var body: some View {
        HStack {
            TextField(user.name, text: $name)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.2))
                )
            Button("Save") {
                update(user.id, name)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
