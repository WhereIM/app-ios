//
//  CaptchaController.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class AboutController: UIViewController, UIWebViewDelegate {
    var service: CoreService?

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()

        let htmlFile = Bundle(for: type(of: self)).bundleURL.appendingPathComponent("whereim.bundle").appendingPathComponent("about.html").path
        let html = try? String(contentsOfFile: htmlFile, encoding: String.Encoding.utf8)

        webView.delegate = self
        webView.loadHTMLString(html!, baseURL: nil)
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
