# TypedJSONObject

DSL to define a bridge from JSON object to your application class, as type safe as possible.

## Getting Started

Define a custom class to handle JSON object with type.

```swift
import TypedJSONobject

class SuperAPIJSON {
  class Person : Object {
    var id: RequiredAttribute<Int>!
    var name: RequiredAttribute<String>!
    var phone: OptionalAttribute<String>!

    override func setupAttributes() {
      self.id = self.requiredIntegerAttribute("id")
      self.name = self.requiredStringAttribute("name")
      self.phone = self.optionalStringAttribute("phone")
    }
  }
}
```

The `Person` class represents a JSON object with

* Number attribute `id`, which always exists
* String attribute `name`, which always exists
* String attribute `phone`, which is optional

Instead of accessing dictionary, use the `Person` object to make sure value of attributes are as you expected.

```swift
func personFromJSON(json: [String: AnyObject]) -> Person {
  return try! SuperAPIJSON.Person.readJSON(json) { object in
    let id: Int = object.id.value
    let name: String = object.name.value
    let phone: String? = object.phone.value

    return Person(id: id, name: name, phone: phone)
  }
}

func personToJSON(person: Person) -> [String: AnyObject] {
  return try! SuperAPIJSON.Person.writeJSON { object in
    object.id.value = person.id
    object.name.value = person.name
    object.phone.value = person.phone
  }
}
```

## Pros

* The library checks if some attributes are missing
* The library translates `AnyObject` to types you want
* Minimize possibility to make typo on attribute name; Swift compiler tells you if you make another typo
* Swift compiler tells you if you are assigning value of unexpected type to attribute
* Classes for JSON objects help you understand the expected JSON structure at glance

## Cons

* You have to define number of classes
* Does not help digging objects so much

## Installation

Install via CocoaPods, from this GIT repo.
No Trunk yet.

## Contributing

Send me your pull request!
