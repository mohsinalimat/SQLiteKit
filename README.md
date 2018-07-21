
# SQLiteKit

a Swift version inspired by [SQLite-net](https://github.com/praeclarum/sqlite-net/).

Using Codable and Mirror technology.


## Features

- [x] ORM 
- [x] Auto table migration

## In-Progress

* Auto increase primary key value is not set when insert into table
* Transcation
* Create Index on table
* ...

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

| Swift Type      | SQLite Type |
| --------------- | ----------- |
| `Int`           | `INTEGER`   |
| `Float `        | `REAL`      |
| `Double `       | `REAL`      |
| `String`        | `TEXT`      |
| `Date`          | `REAL`      |
| `nil`           | `NULL`      |
| `Data`          | `BLOB`      |
| `Optional<T>`   | `T`         |

T should beo one of  `Int`, `Float`, `Double`, `String`, `Date` or `Data`。

## Query

You can use API defined in `SQLiteConnection` to query.

```swift
public func query<T>(_ query: String, parameters: [Any] = []) -> [T]
public func find<T>(_ pk: Any) -> T?
```

Or you can create a queryable object of your table.

```swift
let queryTable: SQLiteTableQuery<T> = db.table() 
```

SQLiteTableQuery<T> have following APIs: 

```swift
public var count: Int { get }
public func toList() -> [T]
public func filter<T: SQLiteTable>(using predicate: NSPredicate) -> [T]
public func orderBy() -> SQLiteTableQuery<T>
```

## Insert

Insert into table is pretty easy.

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
