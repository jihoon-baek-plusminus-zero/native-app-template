//
//  ContentView.swift
//  Native app template
//
//  Created by 백지훈 on 10/14/25.
//

import SwiftUI
import WebKit

// MARK: - WebView Wrapper
struct WebView: NSViewRepresentable {
    let url: String

    func makeNSView(context: Context) -> WKWebView {
        // WKWebView 설정
        let configuration = WKWebViewConfiguration()

        // ========================================
        // PERFORMANCE OPTIMIZATION: 캐싱 전략
        // ========================================
        configuration.websiteDataStore = .default()

        // ========================================
        // PERFORMANCE OPTIMIZATION: 프리페칭 활성화
        // ========================================
        // DNS 프리페칭, 리소스 힌트 등을 활성화
        if #available(macOS 11.0, *) {
            configuration.limitsNavigationsToAppBoundDomains = false
        }

        // 완전한 Safari User Agent 설정 (Google 신원 인증용)
        let safariUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15"
        configuration.applicationNameForUserAgent = safariUserAgent

        // JavaScript 새 창 열기 감지 활성화
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        // ========================================
        // PERFORMANCE OPTIMIZATION: 미디어 최적화
        // ========================================
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // Safari 개발자 도구 활성화
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")

        // ========================================
        // PERFORMANCE OPTIMIZATION: 렌더링 최적화
        // ========================================
        // 빠른 초기 렌더링을 위해 점진적 렌더링 활성화
        configuration.suppressesIncrementalRendering = false

        // WKWebView 인스턴스 생성
        let webView = WKWebView(frame: .zero, configuration: configuration)

        // ========================================
        // PERFORMANCE OPTIMIZATION: 네비게이션 최적화
        // ========================================
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsMagnification = true

        // Safari 스타일 네비게이션 설정
        webView.customUserAgent = safariUserAgent

        // UI Delegate 설정 (새 창 요청 처리용)
        webView.uiDelegate = context.coordinator

        // Navigation Delegate 설정 (성능 모니터링용)
        webView.navigationDelegate = context.coordinator

        return webView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // Coordinator: 새 창 요청을 시스템 브라우저로 전달 + 성능 모니터링
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var hasLoadedInitialURL = false  // 중복 로드 방지 플래그

        // MARK: - WKUIDelegate
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {

            // 새 창 요청 URL 가져오기
            if let url = navigationAction.request.url {
                print("🌐 새 창 요청 감지: \(url.absoluteString)")
                print("   → 시스템 기본 브라우저로 열기")

                // 시스템 기본 브라우저로 열기
                NSWorkspace.shared.open(url)
            }

            // nil 반환 = WebView 내에서는 열지 않음
            return nil
        }

        // MARK: - WKNavigationDelegate (성능 최적화)
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("⚡️ [Performance] 페이지 로딩 시작: \(webView.url?.absoluteString ?? "unknown")")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ [Performance] 페이지 로딩 완료")

            // ========================================
            // PERFORMANCE OPTIMIZATION: JavaScript 최적화
            // ========================================
            // 페이지 로드 후 JavaScript 성능 향상을 위한 설정
            let optimizationScript = """
            // 스크롤 성능 최적화
            if ('CSS' in window && 'supports' in CSS) {
                if (CSS.supports('will-change', 'transform')) {
                    document.documentElement.style.willChange = 'scroll-position';
                }
            }
            """
            webView.evaluateJavaScript(optimizationScript, completionHandler: nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ [Performance] 페이지 로딩 실패: \(error.localizedDescription)")
        }
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // ========================================
        // PERFORMANCE OPTIMIZATION: 중복 로드 방지
        // ========================================
        // 이미 로드된 URL이면 다시 로드하지 않음
        guard let targetURL = URL(string: url) else { return }

        // 현재 로드된 URL과 비교
        if webView.url?.absoluteString == targetURL.absoluteString {
            // 이미 동일한 URL이 로드되어 있으면 스킵
            return
        }

        // 아직 로드되지 않았거나 다른 URL인 경우에만 로드
        if !context.coordinator.hasLoadedInitialURL || webView.url == nil {
            print("🚀 [Performance] 초기 URL 로드: \(targetURL.absoluteString)")

            // JavaScript 설정 (macOS 11.0+)
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true

            // ========================================
            // PERFORMANCE OPTIMIZATION: 캐시 정책 최적화
            // ========================================
            var request = URLRequest(url: targetURL)
            request.cachePolicy = .returnCacheDataElseLoad  // 캐시 우선 사용
            request.timeoutInterval = 30  // 타임아웃 30초

            webView.load(request)
            context.coordinator.hasLoadedInitialURL = true

            // ⚠️ 3초 자동 새로고침 제거됨 - 성능 향상을 위해 제거
            // 이전 코드: DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { webView.reload() }
        }
    }
}

// MARK: - Custom Drag Area
// NSView 확장: 창 드래그 기능
class DraggableView: NSView {
    override public func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

struct CustomDragArea: NSViewRepresentable {
    let backgroundColor: String
    
    func makeNSView(context: Context) -> DraggableView {
        let view = DraggableView()
        view.wantsLayer = true
        view.layer?.backgroundColor = hexToNSColor(backgroundColor).cgColor
        return view
    }
    
    func updateNSView(_ nsView: DraggableView, context: Context) {
        nsView.layer?.backgroundColor = hexToNSColor(backgroundColor).cgColor
    }
    
    // Hex 색상을 NSColor로 변환
    private func hexToNSColor(_ hex: String) -> NSColor {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let red = CGFloat((int >> 16) & 0xFF) / 255.0
        let green = CGFloat((int >> 8) & 0xFF) / 255.0
        let blue = CGFloat(int & 0xFF) / 255.0
        
        return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - Main View
struct ContentView: View {
    var body: some View {
        ZStack(alignment: .top) {
            // 웹뷰 영역 (배경) - 상단에 공백 추가
            VStack(spacing: 0) {
                // 공백 영역
                Color.clear
                    .frame(height: pxToCGFloat(AppConfig.titlebar_height))
                
                // 웹뷰
                if !AppConfig.targetURL.isEmpty {
                    WebView(url: AppConfig.targetURL)
                } else {
                    VStack {
                        ProgressView()
                        Text("로딩 중...")
                            .padding()
                        Text("설정 오류: Config.swift에서 targetURL을 확인하세요")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            // 커스텀 컬러 드래그 영역 (상단에 겹침)
            VStack {
                CustomDragArea(backgroundColor: AppConfig.titlebar_color)
                    .frame(height: pxToCGFloat(AppConfig.titlebar_height))
                
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // 디버깅 로그
            print("📱 App Name: \(AppConfig.appName)")
            print("🌐 Target URL: \(AppConfig.targetURL)")
            print("🦁 User Agent: Safari 17.1 시뮬레이션 모드")
            print("🎨 타이틀바 설정:")
            print("   📏 높이: \(AppConfig.titlebar_height)")
            print("   📝 제목: \(AppConfig.titlebar_title)")
            print("   🎨 색상: \(AppConfig.titlebar_color)")
            print("🖱️ 드래그 영역: 상단 \(AppConfig.titlebar_height) 영역 활성화")
        }
    }
    
    // px 문자열을 CGFloat로 변환
    private func pxToCGFloat(_ pxString: String) -> CGFloat {
        let numberString = pxString.replacingOccurrences(of: "px", with: "").trimmingCharacters(in: .whitespaces)
        return CGFloat(Double(numberString) ?? 40.0)
    }
}

// MARK: - Color Extension (Hex 지원)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let red = Double((int >> 16) & 0xFF) / 255.0
        let green = Double((int >> 8) & 0xFF) / 255.0
        let blue = Double(int & 0xFF) / 255.0
        
        self.init(
            .sRGB,
            red: red,
            green: green,
            blue: blue,
            opacity: 1.0
        )
    }
}

#Preview {
    ContentView()
}
