//
//  wall4macApp.swift
//  wall4mac
//
//  Created by 徐鹏飞 on 2022/10/1.
//

import SwiftUI

@main
struct wall4macApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(EnvObjectsModel())
        }
    }
}
