//
//  ContentView.swift
//  Native app template
//
//  Created by 백지훈 on 10/14/25.
//

import SwiftUI
import WebKit

// MARK: - DraggableWKWebView: Arc/VSCode 스타일 드래그 + 클릭
/// 타이틀바 영역: 드래그로 윈도우 이동
/// 일반 영역: 웹뷰 클릭 정상 작동
class DraggableWKWebView: WKWebView {
    // ========================================
    // 투명 타이틀바 높이: 60px 고정
    // (extra_titlebar 공백과는 별개)
    // ========================================
    private let titlebarHeight: CGFloat = 60.0

    private var mouseDownEvent: NSEvent?
    private var isDraggingWindow = false
    private let dragThreshold: CGFloat = 5.0  // 5픽셀 이상 이동 시 드래그로 인식

    // ========================================
    // STEP 1: mouseDown - 클릭 위치 기록
    // ========================================
    override func mouseDown(with event: NSEvent) {
        let clickLocation = event.locationInWindow
        let windowHeight = self.window?.frame.height ?? 0

        // 타이틀바 영역인지 확인 (윈도우 최상단 40px)
        if clickLocation.y >= (windowHeight - titlebarHeight) {
            // 타이틀바 영역 클릭 → 드래그 가능성 있음
            mouseDownEvent = event
            isDraggingWindow = false
            print("🎯 [Titlebar] 타이틀바 영역 클릭 감지: y=\(clickLocation.y), threshold=\(windowHeight - titlebarHeight)")

            // ⚠️ 중요: mouseDown도 웹뷰에 전달 (클릭 감지를 위해 필수!)
            super.mouseDown(with: event)
        } else {
            // 일반 영역 → 웹뷰로 정상 전달
            mouseDownEvent = nil
            super.mouseDown(with: event)
            print("👆 [WebView] 일반 영역 클릭 → 웹뷰로 전달")
        }
    }

    // ========================================
    // STEP 2: mouseDragged - 드래그 vs 클릭 구분
    // ========================================
    override func mouseDragged(with event: NSEvent) {
        guard let startEvent = mouseDownEvent else {
            super.mouseDragged(with: event)
            return
        }

        // 드래그 거리 계산
        let startLocation = startEvent.locationInWindow
        let currentLocation = event.locationInWindow
        let distance = hypot(
            currentLocation.x - startLocation.x,
            currentLocation.y - startLocation.y
        )

        // 5픽셀 이상 이동 → 드래그로 확정
        if distance > dragThreshold && !isDraggingWindow {
            isDraggingWindow = true
            print("🚀 [Titlebar] 윈도우 드래그 시작 (거리: \(distance)px)")
        }

        if isDraggingWindow {
            // 윈도우 드래그 수행 (웹뷰에 전달 안 함)
            self.window?.performDrag(with: event)
        } else {
            // 아직 드래그 아님 → 웹뷰에 전달 (드래그 제스처일 수 있음)
            super.mouseDragged(with: event)
        }
    }

    // ========================================
    // STEP 3: mouseUp - 클릭 완료 처리
    // ========================================
    override func mouseUp(with event: NSEvent) {
        let wasInTitlebar = (mouseDownEvent != nil)

        if wasInTitlebar && !isDraggingWindow {
            // 타이틀바에서 "클릭"만 했음 (드래그 안 함)
            // → 웹뷰에 mouseUp 전달 (mouseDown + mouseUp = 클릭)
            print("✅ [Titlebar] 클릭 완료 → 웹뷰로 전달")
            super.mouseUp(with: event)
        } else if wasInTitlebar && isDraggingWindow {
            print("✅ [Titlebar] 윈도우 드래그 완료")
            // 드래그 중이었으면 mouseUp 전달 안 함 (윈도우 이동만 수행)
        } else {
            // 일반 영역 → 웹뷰로 정상 전달
            super.mouseUp(with: event)
        }

        // 초기화
        mouseDownEvent = nil
        isDraggingWindow = false
    }
}

// MARK: - WebView Wrapper
struct WebView: NSViewRepresentable {
    let url: String
    var onBackgroundColorDetected: ((Color) -> Void)?

    func makeNSView(context: Context) -> DraggableWKWebView {
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

        // ========================================
        // GPU/METAL 최적화: WKWebView는 기본적으로 GPU 가속 활성화됨
        // ========================================
        // Entitlements의 JIT 및 Metal 권한 덕분에 자동으로 활성화됨
        // 별도의 설정 불필요 - WKWebView가 자동으로 최적화 수행

        // ========================================
        // DraggableWKWebView 인스턴스 생성 (Arc/VSCode 스타일)
        // ========================================
        let webView = DraggableWKWebView(frame: .zero, configuration: configuration)

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
        Coordinator(onBackgroundColorDetected: onBackgroundColorDetected)
    }

    // Coordinator: 새 창 요청을 시스템 브라우저로 전달 + 성능 모니터링
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var hasLoadedInitialURL = false  // 중복 로드 방지 플래그
        var onBackgroundColorDetected: ((Color) -> Void)?

        init(onBackgroundColorDetected: ((Color) -> Void)?) {
            self.onBackgroundColorDetected = onBackgroundColorDetected
            super.init()
        }

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

            // ========================================
            // BACKGROUND COLOR DETECTION: 웹사이트 배경색 감지
            // ========================================
            // extra_titlebar가 true이고, 커스텀 색상이 아닐 때만 감지
            if AppConfig.extra_titlebar && !AppConfig.extra_titlebar_custom_color {
                detectBackgroundColor(webView: webView)
            }
        }

        // 웹사이트 배경색 감지
        private func detectBackgroundColor(webView: WKWebView) {
            let script = """
            (function() {
                // body 배경색 가져오기
                var bodyBg = window.getComputedStyle(document.body).backgroundColor;

                // html 배경색도 확인
                var htmlBg = window.getComputedStyle(document.documentElement).backgroundColor;

                // 투명한 경우 html 배경색 사용
                var bgColor = bodyBg;
                if (bodyBg === 'rgba(0, 0, 0, 0)' || bodyBg === 'transparent') {
                    bgColor = htmlBg;
                }

                // 여전히 투명하면 흰색 사용
                if (bgColor === 'rgba(0, 0, 0, 0)' || bgColor === 'transparent') {
                    bgColor = 'rgb(255, 255, 255)';
                }

                return bgColor;
            })();
            """

            webView.evaluateJavaScript(script) { [weak self] result, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ [Background] 배경색 감지 실패: \(error.localizedDescription)")
                    return
                }

                if let colorString = result as? String {
                    print("🎨 [Background] 감지된 배경색: \(colorString)")
                    let color = self.parseColor(from: colorString)
                    DispatchQueue.main.async {
                        self.onBackgroundColorDetected?(color)
                    }
                }
            }
        }

        // CSS 색상 문자열을 SwiftUI Color로 변환
        private func parseColor(from cssColor: String) -> Color {
            // rgb(r, g, b) 또는 rgba(r, g, b, a) 형식 파싱
            let pattern = "rgba?\\((\\d+),\\s*(\\d+),\\s*(\\d+)"
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: cssColor, range: NSRange(cssColor.startIndex..., in: cssColor)) else {
                print("⚠️ [Background] 색상 파싱 실패, 기본값 사용: \(cssColor)")
                return .white
            }

            let r = (cssColor as NSString).substring(with: match.range(at: 1))
            let g = (cssColor as NSString).substring(with: match.range(at: 2))
            let b = (cssColor as NSString).substring(with: match.range(at: 3))

            guard let red = Double(r), let green = Double(g), let blue = Double(b) else {
                return .white
            }

            let color = Color(
                .sRGB,
                red: red / 255.0,
                green: green / 255.0,
                blue: blue / 255.0,
                opacity: 1.0
            )

            print("✅ [Background] 변환된 색상: RGB(\(red), \(green), \(blue))")
            return color
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ [Performance] 페이지 로딩 실패: \(error.localizedDescription)")
        }
    }
    
    func updateNSView(_ webView: DraggableWKWebView, context: Context) {
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

// MARK: - Main View
struct ContentView: View {
    // 웹사이트 배경색 저장 (기본값: 흰색)
    @State private var websiteBackgroundColor: Color = .white

    // 타이틀바 배경색 계산 (커스텀 색상 또는 자동 감지)
    private var titlebarBackgroundColor: Color {
        if AppConfig.extra_titlebar_custom_color {
            // 커스텀 색상 사용
            return Color(hex: AppConfig.titlebar_color)
        } else {
            // 웹사이트 배경색 자동 감지
            return websiteBackgroundColor
        }
    }

    var body: some View {
        // ========================================
        // Arc/VSCode 스타일: 투명 타이틀바 + 전체 화면 웹뷰
        // ========================================
        // 웹뷰가 화면 전체를 차지하며, DraggableWKWebView가
        // 타이틀바 영역의 드래그/클릭을 자동으로 처리합니다.

        if !AppConfig.targetURL.isEmpty {
            if AppConfig.extra_titlebar {
                // ========================================
                // extra_titlebar = true: 타이틀바 공백 영역 추가
                // ========================================
                VStack(spacing: 0) {
                    // 타이틀바 높이만큼 공백
                    // - custom_color = true: titlebar_color 사용
                    // - custom_color = false: 웹사이트 배경색 사용
                    Rectangle()
                        .fill(titlebarBackgroundColor)
                        .frame(height: pxToCGFloat(AppConfig.titlebar_height))

                    // 웹뷰 (타이틀바 아래부터 시작)
                    WebView(
                        url: AppConfig.targetURL,
                        onBackgroundColorDetected: { color in
                            // 커스텀 색상 모드가 아닐 때만 업데이트
                            if !AppConfig.extra_titlebar_custom_color {
                                websiteBackgroundColor = color
                            }
                        }
                    )
                }
                .ignoresSafeArea()
            } else {
                // ========================================
                // extra_titlebar = false: 웹뷰 전체 화면
                // ========================================
                WebView(
                    url: AppConfig.targetURL,
                    onBackgroundColorDetected: { _ in }  // 배경색 무시
                )
                .ignoresSafeArea()  // Safe area 무시 → 타이틀바까지 확장
            }
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
