## Features

- [x] ORM 
- [] 
- [] Dynamic add column


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
    let path = NSHomeDirectory().appending("db.sqlite")
    let db = SQLiteKit(path: path)
}
```

#### 2. Define your table model

 ```swift
 
 class UserModel: SQLiteModelProtocol {
     let name: String
     let age: Int
     let avatarData: Data
     
     init(name: String, age: Int, avatar: Data) {
         self.name = name
         self.age = age
         self.avatarData = avatarData
     }
     
     // MARK: - SQLiteModelProtocol
     
     static var tableName: String {
         return "Users"
     }
     
     var values: [Any] {
         return [name, age, avatarData]
     }
     
     static var columns: [SQLiteColumn] {
         return [
             SQLiteColumn(name: "name", dataType: .string),
             SQLiteColumn(name: "age", dataType: .int),
             SQLiteColumn(name: "avatarData", dataType: .data)
         ]
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