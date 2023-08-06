</br>

![RealmRepositoryIcon](https://github.com/Kolos65/RealmRepository/assets/26504214/7c82d395-439b-4fb5-a9ea-e2a19d04fe6d)

# Reactive Realm Wrapper

<p align="left">
<img src="https://img.shields.io/badge/platforms-iOS-lightgrey.svg">
<img src="https://img.shields.io/badge/license-MIT-blue">
</p>

A lightweight wrapper around the [RealmSwift](https://github.com/realm/realm-swift) library, specifically made for reactive, event-stream based architectures. **RealmRepository** provides both **async/await** and **Combine** APIs for CRUD operations and offers reactive interfaces. All operations are synchronized with a global actor and utilize [actor-isolated realms](https://www.mongodb.com/docs/realm/sdk/swift/actor-isolated-realm/) for thread-safety. Using **actor-isolated realms** and a custom **detach mechanism** that keeps live objects in isolation ensures compatibility with Swift's modern concurrency features.

## Installation

RealmRepository supports [Swift Package Manager](https://www.swift.org/package-manager/), which is the recommended option.

## Usage

### Setting up RealmStorage

Before diving into CRUD operations, you first need to configure the RealmStorage to connect with your Realm database. `RealmStorageContext` provides the configuration and database access to all `Repository` instances. 

You can access the default `RealmStorageContext` through `RealmStorage.default` or create your own instance. If you chose tha latter, note that you will need to pass that storage to all `Repository` instances.

Before you can use any `Repository` objects you must connect to the underlying storage. I recommend doing this as early as possible in your application lifecycle.
```swift
try await RealmStorage.default.connect()
```

A common use-case is to create different databases for different users. You can do this by providing a database name during connection:
```swift
try await RealmStorage.default.connect(to: "UserId")
```

`RealmRepository` also supports encription using the **`PBKDF2`** key derivation algorithm. If you want to encript your repository you can do so by providing a password and optionally a salt:
```swift
try await RealmStorage.default.connect(to: "UserId", password: "Password", salt: "Salt")
```

### Define a Data Model

Just like working with `RealmSwift` you first need to create a data model that inherits form Realm's Object interface:

```swift
class User: Object {
    @Persisted(primaryKey: true) var id = UUID()
    @Persisted var name: String = ""
    @Persisted var age: Int = 0
    @Persisted var email: String = ""
}
```

After we defined our model we can create a `Repository` instance that can be used to make CRUD operations and listen to changes:

```swift
let repository = Repository<User>()
```

### Create

To insert an object or a collection of objects to the database, use the `insert` method of the repository:

```swift
let user = User(name: "Name", age: 20, email: "email@example.com")

try await repository.insert(user)
```
You can also call these methods with an array of `User` objects.

### Read

To fetch all models once:
```swift
let allUsers = try await repository.get()
```

To fetch a specific object by its primary key:

```swift
let user = try await repository.get(for: userId)
```

To query objects based on a specified inclusion criteria:
```swift
import RealmSwift

let user = try await repository.getBy { $0.name == "John" }
```
Don't forget to import `RealmSwift` otherwise operators won't work on the `Query` proxy.

### Update

If you try to insert an already existing object, an error will be thrown. In many cases you want to be able to create or update models regardless of the fact that they were already created or not:

```swift
let user = User(name: "Name", age: 20, email: "email@example.com")

try await repository.upsert(user)
```
You can also call `upsert(_:)` with an array of objects.

To update a model by mutating its properties you can use:
```swift
try await repository.update(user) {
    $0.name = "Jack"
}
```
You can also `update(_:)` using only primary keys.

### Delete

To remove objects you can use:

```swift
try await repository.remove(user)
```
You can also pass an array to the `remove(_:)` method or remove models using their primary key.

### Reactive Interface

`Repository` provides asynchronous sequences that can be used to react to changes. The `stream` property of a repository returns an `AsyncThrowingStream<[Model], Error>` that receives a new value as soon as any of the objects change.
```swift
for try await users in repository.stream {
    print("User count: \(users.count)")
}
```

If you want to listen to changes of a specific object you can use:
```swift
for try await user in repository.getStream(for: userId) {
    print("User's name is: \(user.name)")
}
```

### Combine

`RealmRepository` has a Combine interface too. All above CRUD methods have a Combine equivalent:
```swift
repository.insertCombine(user)
    .sink(receiveCompletion: { _ in }, receiveValue: {
        print("User inserted")
    })
    .store(in: &cancellables)
```
```swift
repository.upsertCombine(user)
    .sink(receiveCompletion: { _ in }, receiveValue: {
        print("Upsert complete")
    })
    .store(in: &cancellables)
```
```swift
repository.updateCombine(user) { $0.name = "Jack" }
    .sink(receiveCompletion: { _ in }, receiveValue: {
        print("User updated")
    }).store(in: &cancellables)
```
```swift
repository.removeCombine(user)
    .sink(receiveCompletion: { _ in }, receiveValue: {
        print("User deleted")
    })
    .store(in: &cancellables)
```
The Combine equivalent `stream` is the `publisher` property taht emits values of the `Repository` upon changes:
```swift
repository.publisher
    .sink(receiveCompletion: { _ in }, receiveValue: { users in
        print("User count: \(users.count)")
    })
    .store(in: &cancellables)
```
If you need a Combine publisher for a specific model you can use:
```swift
repository.getCombine(for: userId)
    .sink(receiveCompletion: { _ in }, receiveValue: { user in
        print("User's name is: \(user.name)")
    })
    .store(in: &cancellables)
```


## Demo Application
The package contains a demo project for a comprehensive example of how to use **RealmRepository**. Note that the demo project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the project file. See the `README.md` inside the demo project for more info.

The demo app uses the [AsyncBinding](https://github.com/Kolos65/AsyncBinding) package to bind async sequences to SwiftUI states.

## Contributing

Feel free to submit a pull request or open an issue.

## License

`RealmRepository` is made available under the MIT License. Please see the LICENSE file for more details.
