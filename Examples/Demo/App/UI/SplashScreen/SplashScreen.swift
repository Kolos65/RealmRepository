//
//  SplashScreen.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("Show Users") {
                    NavigationLazyView(HomeScreen())
                }
            }
            .navigationTitle("RealmRepository")
        }
    }
}
