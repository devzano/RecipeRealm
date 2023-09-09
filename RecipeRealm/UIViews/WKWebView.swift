//
//  WKWebView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 7/20/23.
//

import SwiftUI
import WebKit
import SafariServices
import Combine

extension UIButton {
    convenience init(imageSystemName: String, target: Any, action: Selector) {
        self.init(type: .system)
        let image = UIImage(systemName: imageSystemName)
        self.setImage(image, for: .normal)
        self.addTarget(target, action: action, for: .touchUpInside)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// MARK: - WKWebViewWithButton

class WebViewWithButton: UIView, WKNavigationDelegate {
    private var observation: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = []
    private var isLoadingPage: Bool = false {
        didSet {
            scanTextButton!.isEnabled = !isLoadingPage
        }
    }

    var request: URLRequest? {
        didSet {
            isLoadingPage = true
            if let request = request {
                webView.load(request)
            }
        }
    }

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private lazy var webURLAndScanButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var webURL: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var scanTextButton: UIButton? = {
        UIButton(imageSystemName: "text.viewfinder", target: self, action: #selector(scanText))
    }()
    
    private lazy var backButton: UIButton = {
        UIButton(imageSystemName: "arrowshape.turn.up.backward.2.circle", target: self, action: #selector(goBack))
    }()
    
    lazy var dismissButton: UIButton? = {
        UIButton(imageSystemName: "xmark.square", target: self, action: #selector(dismissWebView))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(dismissButton!)
        addSubview(backButton)
        addSubview(webView)
        webURLAndScanButtonStackView.addArrangedSubview(webURL)
        webURLAndScanButtonStackView.addArrangedSubview(scanTextButton!)
        addSubview(webURLAndScanButtonStackView)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(copyURL))
        webURL.addGestureRecognizer(longPressGestureRecognizer)
        webURL.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            dismissButton!.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            dismissButton!.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            webView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webURLAndScanButtonStackView.topAnchor, constant: -10),

            webURLAndScanButtonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            webURLAndScanButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            webURLAndScanButtonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            scanTextButton!.widthAnchor.constraint(equalToConstant: 44),
        ])
        
        observation = webView.publisher(for: \.canGoBack)
            .sink { [weak self] canGoBack in
                self?.backButton.isEnabled = canGoBack
            }
    
        webView.publisher(for: \.url)
            .compactMap { $0 }
            .sink { [weak self] url in
                self?.webURL.text = url.absoluteString
            }
            .store(in: &cancellables)
        
        setupWebViewObservations()
        webView.navigationDelegate = self
        scanTextButton!.isEnabled = false
    }
    
    func setupWebViewObservations() {
        observation = webView.publisher(for: \.canGoBack)
            .sink { [weak self] canGoBack in
                self?.backButton.isEnabled = canGoBack
            }
        
        webView.publisher(for: \.url)
            .compactMap { $0 }
            .sink { [weak self] url in
                self?.webURL.text = url.absoluteString
            }
            .store(in: &cancellables)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoadingPage = false
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoadingPage = true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scanning

    @objc private func scanText() {
        scanTextButton!.isEnabled = false
        executeJavascript(script: scanScript) { [weak self] result in
            defer {
                self?.scanTextButton!.isEnabled = true
            }
            
            switch result {
            case .success(let combinedText):
                let parsedResults = self?.parseText(combinedText) ?? []
                if parsedResults.isEmpty {
                    let errorMessage = "No keywords found on the webpage."
                    self?.presentErrorViewController(message: errorMessage)
                } else {
                    let scannedTextViewController = ScannedTextViewController(text: parsedResults.map { $0.extractedText }.joined())
                    self?.parentViewController?.present(scannedTextViewController, animated: true, completion: nil)
                }
                
            case .failure(let error):
                print("Error: \(error)")
                let errorMessage = "An error occurred while scanning the web page: \(error)"
                self?.presentErrorViewController(message: errorMessage)
            }
        }
    }

    private let scanScript = """
        function extractFirstListFromElements(selector) {
            var elements = document.querySelectorAll(selector);
            if (elements.length > 0) {
                var items = elements[0].innerText.split("\\n");
                return items.join("\\n");
            }
            return '';
        }

        var ingredients = extractFirstListFromElements("[class*='ingredient'], [class*='ingr']");
        var steps = extractFirstListFromElements("[class*='step']");
        var instructions = extractFirstListFromElements("[class*='instruction']");
        var directions = extractFirstListFromElements("[class*='direction'], [class*='dir']");
        ingredients + '|~|' + steps + '|~|' + instructions + '|~|' + directions;
    """

    // MARK: - Parsing and Filtering

    private func parseText(_ combinedText: String) -> [(keyword: String, extractedText: String)] {
        let keywords = ["ingredients", "steps", "instructions", "directions"]
        let extractedTexts = combinedText.components(separatedBy: "|~|")
        var parsedText: [(keyword: String, extractedText: String)] = []

        for (index, keyword) in keywords.enumerated() {
            let extractedText = index < extractedTexts.count ? extractedTexts[index] : ""
            if !extractedText.isEmpty {
                parsedText.append((keyword: keyword, extractedText: "Here's the \(keyword) list:\n\(extractedText)\n\n"))
            } else {
                parsedText.append((keyword: keyword, extractedText: "The \(keyword) list was NOT found on the webpage.\n\n"))
            }
        }
        return parsedText
    }

    // MARK: - Error Handling

    private func presentErrorViewController(message: String) {
        let errorViewController = ScannedTextViewController(text: message)
        parentViewController?.present(errorViewController, animated: true, completion: nil)
    }

    func executeJavascript(script: String, completionHandler: ((Result<String, Error>) -> Void)?) {
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error)")
                    completionHandler?(.failure(error))
                    return
                }
                if let combinedText = result as? String {
                    completionHandler?(.success(combinedText))
                }
            }
        }

    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc private func copyURL(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            UIPasteboard.general.string = webURL.text

            if let viewController = self.parentViewController {
                let alert = UIAlertController(title: nil, message: "URL copied to clipboard", preferredStyle: .alert)
                viewController.present(alert, animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    alert.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc private func dismissWebView() {
        if let viewController = self.parentViewController {
            viewController.dismiss(animated: true, completion: nil)
        }
    }
}

struct WebViewWithButtonRepresentable: UIViewRepresentable {
    let request: URLRequest
    let showScanButton: Bool
    let showCloseButton: Bool

    func makeUIView(context: Context) -> WebViewWithButton {
        let view = WebViewWithButton()
        view.request = request
        if !showScanButton {
            view.scanTextButton?.isHidden = true
        }
        if !showCloseButton {
            view.dismissButton?.isHidden = true
        }
        return view
    }

    func updateUIView(_ uiView: WebViewWithButton, context: Context) {
        uiView.request = request
        if !showScanButton {
            uiView.scanTextButton?.isHidden = true
        }
        if !showCloseButton {
            uiView.dismissButton?.isHidden = true
        }
    }
}


class ScannedTextViewController: UIViewController {
    private let textView = UITextView()
    private let copyButton = UIButton(type: .system)
    private let dismissButton = UIButton(type: .system)

    private let scannedText: String

    init(text: String) {
        self.scannedText = text
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        textView.text = scannedText
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        copyButton.setTitle("Copy", for: .normal)
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(copyButton)
        
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: copyButton.topAnchor, constant: -16),
            
            copyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            copyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissButton.centerYAnchor.constraint(equalTo: copyButton.centerYAnchor),
            dismissButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16)
        ])
    }

    @objc private func copyButtonTapped() {
        UIPasteboard.general.string = scannedText
        let alert = UIAlertController(title: nil, message: "The scanned text has been copied to the clipboard.", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alert.dismiss(animated: true)
        }
    }
    
    @objc private func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
