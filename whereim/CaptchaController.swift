//
//  CaptchaController.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class CaptchaController: UIViewController, UIWebViewDelegate {
    var service: CoreService?

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()

        let url = URL(string: Config.CAPTCHA_URL)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        webView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url!.absoluteString
        let prefix = Config.CAPTCHA_PREFIX
        if(url.hasPrefix(prefix)){
            let otp = url.substring(from: prefix.index(prefix.startIndex, offsetBy: prefix.count))
            service!.setOTP(otp: otp)

            let vc = storyboard?.instantiateViewController(withIdentifier: "login")
            self.present(vc!, animated: true)

            return false
        }
        
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
