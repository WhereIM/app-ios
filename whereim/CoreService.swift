//
//  CoreService.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import AWSIoT

protocol RegisterClientCallback {
    func onCaptchaRequired()
    func onExhausted()
    func onDone()
}

class CoreService {
    private static var service: CoreService?

    static func bind() -> CoreService{
        if service == nil {
            service = CoreService()
            service!.initialize()
        }
        return service!
    }

    private var otp: String?
    private var clientId: String?

    func initialize(){
        print("initialize")
    }

    func getClientId() -> String? {
        return clientId
    }

    func setOTP(otp: String) {
        self.otp = otp
    }

    func register_client(authProvider: String, authId: String, name: String, callback: RegisterClientCallback) {
        if otp == nil || otp!.isEmpty {
            callback.onCaptchaRequired()
            return
        }
        print(authProvider)
        print(authId)
        print(name)
    }
}
