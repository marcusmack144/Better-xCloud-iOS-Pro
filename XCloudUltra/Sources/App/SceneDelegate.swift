import UIKit
import WebKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate, WKNavigationDelegate {
    var window: UIWindow?
    private var webView: WKWebView?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let contentController = WKUserContentController()
        if let scriptURL = Bundle.main.url(forResource: "better-xcloud.user", withExtension: "js"),
           let source = try? String(contentsOf: scriptURL, encoding: .utf8) {
            contentController.addUserScript(
                WKUserScript(
                    source: source,
                    injectionTime: .atDocumentEnd,
                    forMainFrameOnly: false
                )
            )
        }

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.load(URLRequest(url: URL(string: "https://www.xbox.com/play")!))
        self.webView = webView

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = WebViewController(webView: webView)
        self.window = window
        window.makeKeyAndVisible()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
    }
}

private final class WebViewController: UIViewController {
    private let webView: WKWebView

    init(webView: WKWebView) {
        self.webView = webView
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = webView
    }
}
