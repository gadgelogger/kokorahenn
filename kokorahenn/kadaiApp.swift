//
//  kadaiApp.swift
//  kadai
//
//  Created by gadgelogger on 2023/05/04.
//
import SwiftUI

@main
struct KadaiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocationManager())
        }
    }
}
