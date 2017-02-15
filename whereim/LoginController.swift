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


class LoginController: UIViewController, LoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        loginButton.delegate = self

        view.addSubview(loginButton)
        if let token = FBSDKAccessToken.current(){
            print("cached token.uid=\(token.userID)");
        }else{
            print("no token")
        }
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
            print("uid=\(token.userId)")
        }
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {

    }
}

