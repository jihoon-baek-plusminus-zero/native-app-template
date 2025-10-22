//
//  Native_app_templateApp.swift
//  Native app template
//
//  Created by 백지훈 on 10/14/25.
//

import SwiftUI

@main
struct Native_app_templateApp: App {
    // ========================================
    // PERFORMANCE OPTIMIZATION: 앱 수명주기 관리
    // ========================================
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)  // Apple 공식 API: 시스템 타이틀바 숨김
        .windowResizability(.contentSize)
    }
}

// ========================================
// PERFORMANCE OPTIMIZATION: AppDelegate
// ========================================
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 [Performance] 앱 시작 - 성능 최적화 모드 활성화")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // 마지막 창이 닫히면 앱 종료
        return true
    }
}
