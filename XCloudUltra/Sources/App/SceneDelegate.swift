import UIKit
import WebKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let webView = WKWebView(frame: .zero)
        webView.load(URLRequest(url: URL(string: "https://www.xbox.com/play")!))

        let rootViewController = UIViewController()
        rootViewController.view = webView

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootViewController
        self.window = window
        window.makeKeyAndVisible()
    }
}
