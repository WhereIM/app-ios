//
//  ViewController.swift
//  whereim
//
//  Created by Buganini Q on 13/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit


class LoginController: UIViewController, LoginButtonDelegate, RegisterClientCallback {
    var service: CoreService?
    var loginButton: LoginButton?
    var retryButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()

        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.FBSDKProfileDidChange, object: nil, queue: nil) { (Notification) in
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.FBSDKProfileDidChange, object: nil)
            self.checkProfile()
        }

        loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton!.delegate = self
        loginButton!.isHidden = true
        loginButton?.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(loginButton!)

        loginButton!.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75).isActive = true

        retryButton = UIButton()
        retryButton!.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        retryButton!.backgroundColor = .clear
        retryButton!.layer.cornerRadius = 5
        retryButton!.layer.borderWidth = 1
        retryButton!.layer.borderColor = UIColor.gray.cgColor
        retryButton!.translatesAutoresizingMaskIntoConstraints = false
        retryButton!.setTitle("retry".localized, for: .normal)
        retryButton!.isHidden = true
        retryButton!.addTarget(self, action: #selector(retry(sender:)), for: .touchUpInside)

        view.addSubview(retryButton!)

        retryButton!.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        retryButton!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75).isActive = true
    }

    func retry(sender: Any) {
        register_client()
    }

    override func viewDidAppear(_ animated: Bool) {
        tried = false
        checkLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .failed(let error):
            print(error)
        case .cancelled:
            print("Cancelled")
        case .success(_, _, let token):
            profileChecked = false
            tried = true
            loginButton.isHidden = true
            auth_provider = Key.FACEBOOK
            auth_id = token.userId
        }
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {

    }

    var profileChecked = false
    func checkProfile() {
        if profileChecked {
            return
        }
        profileChecked = true
        let profile = FBSDKProfile.current()
        if profile != nil {
            auth_name = profile!.name

            UserDefaults.standard.set(auth_provider, forKey: Key.PROVIDER)
            UserDefaults.standard.set(auth_id, forKey: Key.ID)
            UserDefaults.standard.set(auth_name, forKey: Key.NAME)

            register_client()
        }
    }

    var auth_id: String?
    var auth_provider: String?
    var auth_name: String?

    func register_client() {
        self.view.makeToastActivity(.center)
        service?.register_client(authProvider: auth_provider!, authId: auth_id!, name: auth_name!, callback: self)
    }

    func onCaptchaRequired() {
        self.view.hideToastActivity()
        let vc = storyboard?.instantiateViewController(withIdentifier: "captcha")
        self.present(vc!, animated: true)
    }

    func onExhausted() {
        self.view.hideToastActivity()
        self.view.makeToast("error_exhausted".localized)
        checkLogin()
    }

    func onDone() {
        self.view.hideToastActivity()
        checkLogin()
    }

    var tried = false

    func checkLogin() {
        if service!.getClientId() == nil {
            auth_id = UserDefaults.standard.string(forKey: Key.ID)
            auth_provider = UserDefaults.standard.string(forKey: Key.PROVIDER)
            auth_name = UserDefaults.standard.string(forKey: Key.NAME)

            if auth_id == nil {
                retryButton!.isHidden = true
                loginButton!.isHidden = false
            } else {
                loginButton!.isHidden = true
                if !tried {
                    tried = true
                    register_client()
                } else {
                    retryButton!.isHidden = false
                }
            }
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "startup")
            self.present(vc!, animated:true, completion: nil)
        }
    }
}

