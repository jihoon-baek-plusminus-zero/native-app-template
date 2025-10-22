//
//  Native_app_templateApp.swift
//  Native app template
//
//  Created by 백지훈 on 10/14/25.
//

import SwiftUI

@main
struct Native_app_templateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)  // Apple 공식 API: 시스템 타이틀바 숨김
        .windowResizability(.contentSize)
    }
}
