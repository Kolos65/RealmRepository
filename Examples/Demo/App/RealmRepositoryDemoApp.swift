//
//  RealmRepositoryDemoApp.swift
//  RealmRepositoryDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import SwiftUI
import Resolver
import RealmRepository

@main
struct RealmRepositoryDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup { SplashScreen() }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    @LazyInjected var storage: RealmStorage

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Resolver.registerAppDependencies()
        Task { try await RealmStorage.default.connect() }
        return true
    }
}
