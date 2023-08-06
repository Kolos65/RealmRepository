//
//  RealmActor.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

/// A global actor that provides synchronization for accessing and modifying Realm database objects.
///
/// This actor ensures thread-safe operations with the Realm database to prevent concurrency issues. Do not use `RealmActor` for any operation in your project.
@globalActor
public actor RealmActor: GlobalActor {
    public static var shared = RealmActor()
}
