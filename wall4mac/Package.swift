//
//  Package.swift
//  wall4mac
//
//  Created by lwen on 2022/11/6.
//

import PackageDescription

let package = Package(
    name: "wall4mac",
    products: [
        .library(name: "wall4mac", targets: ["wall4mac"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "wall4mac", dependencies: [], path: "wall4mac")
    ]
)
