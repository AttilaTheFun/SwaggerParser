# Swagger Parser

SwagerParser is a swift implementation of the [OpenAPI 2.0 Specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md). (F.K.A. Swagger)
This library is intended for use in conjunction with templating engines like [Stencil](https://github.com/kylef/Stencil).
Together, you can write templates to generate boilerplate code in the language of your choosing from API documentation.

## Prerequisites

The current (and only maintained) version of SwaggerParser requires Swift 4.0+ because it uses the builtin Codable protocols.
It has no dependencies and compiles for macOS 10.13. It would probably compile on linux and older versions of macOS but this is untested.

## Installing

SwaggerParser is available through the Swift Package Manager.
To install the package, add the following to your Package.swift file:

```
        .Package(url: "https://github.com/AttilaTheFun/SwaggerParser.git", majorVersion: 0, minor: 5)
```

And run `swift package update` to install the library.
To use the library, import the module and try to instantiate an instance of the Swagger type,
either from JSON data or a JSON string:

```
import SwaggerParser

...

let jsonString = // load the swagger file into a string
let swagger = try Swagger(from: jsonString)

// Prints: "Gets the user with the specified ID"
print(swagger.paths["/users/{user_id}"].operations[.get]?.description) 
```

## Running the tests

This package has tests that can be run with `swift package test` or within Xcode by generating an xcodeproj
with `swift package generate-xcodeproj`.

## Contributing

Contributions are welcome, and if you find an issue with the library please report it in the github issues section.
To make a contribution, fork the repository, make your changes, and open a pull request into the master branch.

## Versioning

We use [SemVer](http://semver.org/) for versioning.
Until version 1.0 is reached, minor versions can be source-breaking, but patch versions are not.

## Contributors

Logan Shire - [AttilaTheFun](https://github.com/AttilaTheFun)
Wrote core library and ported it to Swift 4 / Codable.

Westin Newell - [n8chur](https://github.com/n8chur)
Contributed support for `allOf`, `x-nullable`, `x-abstract`, `example`, `discriminator`, and more.

Yonas Kolb - [yonaskolb](https://github.com/yonaskolb)
Contributed to parsing of metadata, versions, cyclic references, and missing operation properties.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
