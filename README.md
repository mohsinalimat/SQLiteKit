
# SQLiteKit

a portal of [SQLite-net](https://github.com/praeclarum/sqlite-net/)


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

#### 1. Create your database file

```swift

func createDatabase() {
    let dbPath = NSHomeDirectory().appending("db.sqlite")
    let db = SQLiteConnection(databasePath: dbPath)
}
```

#### 2. Define your table model

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
 ```
 
 #### 3. Insert data
 
 ```swift
 func addUser(_ name: String, age: Int, avatarData: Data) {
     let user = User(name: name, age: age, avatarData: avatarData)
     // TODO
 }
 ```

 #### 4. add new column

 just add new column in your Table model. SQLiteKit automatically alter table and add new columns.

## Author

alexiscn

## License

SQLiteKit is released under the MIT license. [See LICENSE](https://github.com/alexiscn/SQLiteKit/blob/master/LICENSE) for details.
