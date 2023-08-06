//
//  HomeScreen.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import SwiftUI
import Resolver
import AsyncBinding

struct HomeScreen: View {

    // MARK: Injected Properties

    @InjectedObject private var viewModel: HomeScreenViewModel

    // MARK: Private Properties

    @AsyncBinding private var users = [User]()
    @State private var selectedUser: User?

    // MARK: UI

    var body: some View {
        userList
            .navigationBarTitle("Users")
            .toolbar { toolBar }
            .bind { viewModel.users.assign(to: $users) }
            .sheet(item: $selectedUser) { user in
                UserDetail(user: user) { id, name in
                    viewModel.renameUser(with: id, to: name)
                }
            }
    }

    private var toolBar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewModel.addUser()
            } label: {
                Image(systemName: "person.crop.circle.badge.plus")
            }
        }
    }

    private var userList: some View {
        List {
            ForEach(users) { user in
                Button {
                    selectedUser = user
                } label: {
                    cell(user)
                }
            }
        }
    }

    private func cell(_ user: User) -> some View {
        HStack {
            Text(user.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.black)
            Spacer()
            Image(systemName: "trash.fill")
                .foregroundColor(Color.red)
                .onTapGesture {
                    viewModel.deleteUser(with: user.id)
                }
        }
    }
}
