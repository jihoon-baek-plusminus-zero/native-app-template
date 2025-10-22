//
//  Config.swift
//  Native app template
//
//  Created by 백지훈 on 10/14/25.
//

import Foundation

// MARK: - 앱 설정 변수
/// 새로운 앱을 만들 때 이 파일의 값만 수정하세요!
struct AppConfig {
    /// 앱 이름
    static let appName = "test_app_google"
    
    /// 감쌀 웹사이트 URL
    static let targetURL = "https://www.google.com"
    
    // MARK: - 타이틀바 커스터마이징
    /// 타이틀바 색상 (Hex 코드)
    static let titlebar_color = "#ff2200"  // Google 블루
    
    /// 타이틀바 제목
    static let titlebar_title = "Google App"
    
    /// 타이틀바 높이 (px 단위)
    static let titlebar_height = "40px"
}

