
# SQLiteKit

a Swift version of [SQLite-net](https://github.com/praeclarum/sqlite-net/).

Using Codable and Mirror technology.


## Features

- [x] ORM 
- [x] Auto table migration


## Requirements

- iOS 10.0+
- Xcode 9.0+ 
- Swift 4.0+

## Installation


SQLiteKit is available through CocoaPods. To install it, simply add the following line to your Podfile:


```ruby
pod 'SQLiteKit'
```

## Example 

```swift

class User: SQLiteTable {
    var userID: Int
    var name: String
    var age: Int
    var avatarData: Data?
     
    required init() {
        self.name = ""
        self.age = 0
        self.avatarData = nil
    }
     
    // MARK: - SQLiteTable
     
    static func sqliteAttributes: [SQLiteAttribute] {
         return []
    }
}

func SQLitKitDemo() {
    // 1. Create your database file
    let dbPath = NSHomeDirectory().appending("db.sqlite")
    let db = SQLiteConnection(databasePath: dbPath)
    db.create(User.self)
    let user = User(name: "alexiscn", age: 20, avatarData: nil)
    db.insert(user)
}
```

## Support Type

SQLiteTable support following native Swift Types.

```swift
Int
Float
Double
String
Date
Data
Optional<T>
```

T should beo one of  `Int`, `Float`, `Double`, `String`, `Date` or `Data`。

## Query

```swift
public func query<T>(_ query: String, parameters: [Any] = []) -> [T]
public func find<T>(_ pk: Any) -> T?
```

## Insert

```swift

public func insert(_ obj: SQLiteTable?) -> Int
public func insertOrReplace(_ obj: SQLiteTable?) -> Int
public func insertAll(_ objects: [SQLiteTable], inTranscation: Bool = false) -> Int
```

## Update

```swift
public func update(_ obj: SQLiteTable) -> Int

```

## Delete

```swift
public func delete(_ obj: SQLiteTable) -> Int
public func deleteAll<T: SQLiteTable>(_ type: T.Type) -> Int
```

## Author

alexiscn

## License

SQLiteKit is released under the MIT license. [See LICENSE](https://github.com/alexiscn/SQLiteKit/blob/master/LICENSE) for details.
