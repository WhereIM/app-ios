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

    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()

        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.FBSDKProfileDidChange, object: nil, queue: nil) { (Notification) in
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.FBSDKProfileDidChange, object: nil)
            self.checkProfile()
        }

        loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton!.center = view.center
        loginButton!.delegate = self
        loginButton!.isHidden = true

        view.addSubview(loginButton!)
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
        service?.register_client(authProvider: auth_provider!, authId: auth_id!, name: auth_name!, callback: self)
    }

    func onCaptchaRequired() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "captcha")
        self.present(vc!, animated: true)
    }

    func onExhausted() {
        // show exhausted message
    }

    func onDone() {
        checkLogin()
    }

    var tried = false

    func checkLogin() {
        if service!.getClientId() == nil {
            auth_id = UserDefaults.standard.string(forKey: Key.ID)
            auth_provider = UserDefaults.standard.string(forKey: Key.PROVIDER)
            auth_name = UserDefaults.standard.string(forKey: Key.NAME)

            if auth_id == nil {
                loginButton!.isHidden = false
            } else {
                loginButton!.isHidden = true
                if !tried {
                    tried = true
                    register_client()
                } else {
                    // show retry button
                }
            }
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "channel_list")
            let navController = UINavigationController(rootViewController: vc!)
            self.present(navController, animated:true, completion: nil)
        }
    }
}

