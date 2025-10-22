//
//  ContentView.swift
//  Native app template
//
//  Created by 백지훈 on 10/14/25.
//

import SwiftUI
import WebKit

// MARK: - Custom WKWebView with Context Menu
class CustomWKWebView: WKWebView {
    var lastClickedURL: URL?

    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        // 마우스 클릭 위치에서 링크 URL 찾기
        let point = convert(event.locationInWindow, from: nil)

        // JavaScript로 클릭된 요소의 링크 가져오기
        evaluateJavaScript("""
            (function() {
                var element = document.elementFromPoint(\(point.x), \(point.y));
                while (element && element.tagName !== 'A') {
                    element = element.parentElement;
                }
                if (element && element.tagName === 'A') {
                    return element.href;
                }
                return null;
            })();
        """) { [weak self] result, error in
            if let urlString = result as? String, let url = URL(string: urlString) {
                self?.lastClickedURL = url
            }
        }

        // 기존 메뉴 항목 제거 (불필요한 항목들)
        menu.removeAllItems()

        // 링크가 있는 경우 "기본 웹 브라우저에서 열기" 추가
        if lastClickedURL != nil {
            let openInBrowserItem = NSMenuItem(
                title: "기본 웹 브라우저에서 열기",
                action: #selector(openInDefaultBrowser),
                keyEquivalent: ""
            )
            openInBrowserItem.target = self
            menu.addItem(openInBrowserItem)
            menu.addItem(NSMenuItem.separator())
        }

        // 기본 네비게이션 항목들
        let backItem = NSMenuItem(
            title: "뒤로",
            action: #selector(goBack),
            keyEquivalent: ""
        )
        backItem.isEnabled = canGoBack
        menu.addItem(backItem)

        let forwardItem = NSMenuItem(
            title: "앞으로",
            action: #selector(goForward),
            keyEquivalent: ""
        )
        forwardItem.isEnabled = canGoForward
        menu.addItem(forwardItem)

        let reloadItem = NSMenuItem(
            title: "새로고침",
            action: #selector(reload),
            keyEquivalent: ""
        )
        menu.addItem(reloadItem)

        super.willOpenMenu(menu, with: event)
    }

    @objc private func openInDefaultBrowser() {
        if let url = lastClickedURL {
            print("🌐 기본 브라우저에서 열기: \(url.absoluteString)")
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - WebView Wrapper
struct WebView: NSViewRepresentable {
    let url: String

    func makeNSView(context: Context) -> CustomWKWebView {
        // WKWebView 설정
        let configuration = WKWebViewConfiguration()

        // 쿠키/캐시 자동 저장
        configuration.websiteDataStore = .default()

        // 완전한 Safari User Agent 설정 (Google 신원 인증용)
        let safariUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15"
        configuration.applicationNameForUserAgent = safariUserAgent

        // JavaScript 새 창 열기 감지 활성화
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        // CSS/리소스 로딩 최적화
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // Safari 개발자 도구 활성화
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")

        // Safari와 동일한 보안 설정
        configuration.suppressesIncrementalRendering = false

        // ⚡ 성능 최적화 설정
        // 1. 하드웨어 가속 및 GPU 렌더링 최적화
        configuration.preferences.setValue(true, forKey: "acceleratedDrawingEnabled")
        configuration.preferences.setValue(true, forKey: "canvasUsesAcceleratedDrawing")
        configuration.preferences.setValue(true, forKey: "webGLEnabled")

        // 2. 메모리 캐시 최적화
        configuration.preferences.setValue(true, forKey: "offlineWebApplicationCacheEnabled")

        // 3. 이미지 및 애니메이션 성능 향상
        configuration.preferences.setValue(true, forKey: "compositingBordersVisible")
        configuration.preferences.setValue(true, forKey: "compositingRepaintCountersVisible")

        let webView = CustomWKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true

        // Safari 스타일 네비게이션 설정
        webView.customUserAgent = safariUserAgent

        // ⚡ 렌더링 성능 최적화
        webView.setValue(true, forKey: "drawsBackground")

        // Layer 백업 설정으로 애니메이션 성능 향상
        if let layer = webView.layer {
            layer.drawsAsynchronously = true  // 비동기 렌더링
            layer.shouldRasterize = false     // 래스터화는 비활성화 (동적 콘텐츠에 유리)
        }

        // UI Delegate 설정 (새 창 요청 처리용)
        webView.uiDelegate = context.coordinator

        // Navigation Delegate 설정 (링크 처리용)
        webView.navigationDelegate = context.coordinator

        return webView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // Coordinator: 새 창 요청을 시스템 브라우저로 전달
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        // 새 창/새 탭 요청을 기본 브라우저로 전달
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {

            // 새 창 요청 URL 가져오기
            if let url = navigationAction.request.url {
                print("🌐 새 창/새 탭 요청 감지: \(url.absoluteString)")
                print("   → 시스템 기본 브라우저로 열기")

                // 시스템 기본 브라우저로 열기
                NSWorkspace.shared.open(url)
            }

            // nil 반환 = WebView 내에서는 열지 않음
            return nil
        }

        // target="_blank" 링크를 기본 브라우저에서 열기
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            // target="_blank" 링크 감지
            if navigationAction.targetFrame == nil {
                if let url = navigationAction.request.url {
                    print("🌐 target='_blank' 링크 감지: \(url.absoluteString)")
                    print("   → 시스템 기본 브라우저로 열기")
                    NSWorkspace.shared.open(url)
                    decisionHandler(.cancel)
                    return
                }
            }

            decisionHandler(.allow)
        }
    }

    func updateNSView(_ webView: CustomWKWebView, context: Context) {
        if let url = URL(string: url) {
            // 최신 JavaScript 설정 (macOS 11.0+)
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true

            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            webView.load(request)
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
