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
import GoogleSignIn

class LoginController: UIViewController, LoginButtonDelegate, RegisterClientCallback, GIDSignInDelegate, GIDSignInUIDelegate {
    var service: CoreService?
    var facebookLoginButton: LoginButton?
    var googleLoginButton: GIDSignInButton?
    let loginButtonLayout = UIStackView()
    var retryButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()

        service = CoreService.bind()

        loginButtonLayout.translatesAutoresizingMaskIntoConstraints = false
        loginButtonLayout.axis = .vertical
        loginButtonLayout.alignment = .center
        loginButtonLayout.distribution = .fill
        loginButtonLayout.spacing = 10
        loginButtonLayout.isHidden = true

        facebookLoginButton = LoginButton(readPermissions: [ .publicProfile ])
        facebookLoginButton!.delegate = self
        facebookLoginButton?.translatesAutoresizingMaskIntoConstraints = false

        loginButtonLayout.addArrangedSubview(facebookLoginButton!)

        googleLoginButton = GIDSignInButton()
        googleLoginButton?.translatesAutoresizingMaskIntoConstraints = false

        loginButtonLayout.addArrangedSubview(googleLoginButton!)

        view.addSubview(loginButtonLayout)

        loginButtonLayout.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButtonLayout.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75).isActive = true

        retryButton = UIButton()
        retryButton!.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        retryButton!.backgroundColor = .gray
        retryButton!.setTitleColor(.white, for: .normal)
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

        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        NotificationCenter.default.addObserver(self, selector: #selector(onProfileUpdated(notification:)), name:NSNotification.Name.FBSDKProfileDidChange, object: nil)
    }

    @objc func onProfileUpdated(notification: NSNotification) {
        self.checkProfile()
    }

    @objc func retry(sender: Any) {
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
            loginButtonLayout.isHidden = true
            auth_provider = Key.FACEBOOK
            auth_id = token.userId
            auth_token = token.authenticationToken
            checkProfile()
        }
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {

    }

    var profileChecked = false
    func checkProfile() {
        if profileChecked {
            return
        }
        if let profile = FBSDKProfile.current() {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.FBSDKProfileDidChange, object: nil)
            profileChecked = true
            auth_name = profile.name
            register_client()
        }
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            auth_provider = Key.GOOGLE
            auth_id = user.userID
            auth_token = user.authentication.idToken
            auth_name = user.profile.name
            register_client()
        } else {
            print("\(error.localizedDescription)")
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // noop
    }

    var auth_id: String?
    var auth_token: String?
    var auth_provider: String?
    var auth_name: String?

    func register_client() {
        UserDefaults.standard.set(auth_provider, forKey: Key.PROVIDER)
        UserDefaults.standard.set(auth_token, forKey: Key.TOKEN)
        UserDefaults.standard.set(auth_id, forKey: Key.ID)
        UserDefaults.standard.set(auth_name, forKey: Key.NAME)

        guard let provider = auth_provider else {
            return
        }

        guard let token = auth_token else {
            return
        }

        guard let id = auth_id else {
            return
        }

        guard let name = auth_name else {
            return
        }

        self.view.makeToastActivity(.center)
        service?.register_client(authProvider: provider, authToken: token, authId: id, name: name, callback: self)
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
            auth_id = UserDefaults.standard.string(forKey: Key.ID) ?? auth_id
            auth_provider = UserDefaults.standard.string(forKey: Key.PROVIDER) ?? auth_provider
            auth_token = UserDefaults.standard.string(forKey: Key.TOKEN) ?? auth_token
            auth_name = UserDefaults.standard.string(forKey: Key.NAME) ?? auth_name

            UserDefaults.standard.removeObject(forKey: Key.ID)
            UserDefaults.standard.removeObject(forKey: Key.PROVIDER)
            UserDefaults.standard.removeObject(forKey: Key.TOKEN)
            UserDefaults.standard.removeObject(forKey: Key.NAME)

            if auth_id == nil {
                retryButton!.isHidden = true
                loginButtonLayout.isHidden = false
            } else {
                loginButtonLayout.isHidden = true
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

