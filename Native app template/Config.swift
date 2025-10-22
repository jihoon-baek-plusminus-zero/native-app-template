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
    static let targetURL = "https://notebooklm.google.com"
    
    // MARK: - 타이틀바 커스터마이징
    /// 타이틀바 색상 (Hex 코드)
    static let titlebar_color = "#ff2200"  // Google 블루

    /// 타이틀바 제목
    static let titlebar_title = "Google App"

    /// 추가 타이틀바 영역 표시 여부
    /// - true: 웹뷰 상단에 titlebar_height만큼 공백 추가 (웹사이트 배경색 적용)
    /// - false: 웹뷰가 타이틀바 뒤까지 확장 (투명 배경, 드래그 영역 60px 고정)
    static let extra_titlebar = true

    /// 추가 타이틀바 공백 높이 (extra_titlebar = true일 때만 사용)
    /// 참고: 투명 타이틀바의 드래그 가능 영역은 항상 60px 고정
    static let titlebar_height = "30px"

    /// 추가 타이틀바 배경색 직접 지정 여부 (extra_titlebar = true일 때만 사용)
    /// - true: titlebar_color 값을 배경색으로 사용 (커스텀 색상)
    /// - false: 웹사이트 배경색 자동 감지 (동적)
    static let extra_titlebar_custom_color = false
}

