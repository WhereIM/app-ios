//
//  CoreService.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import Alamofire
import Moscapsule

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

    let KEY_FILE = "whereim.key"
    let CRT_FILE = "whereim.crt"
    private var otp: String?
    private var clientId: String?

    func initialize(){
        clientId = UserDefaults.standard.string(forKey: Key.CLIENT_ID)

        moscapsule_init()
        
        if clientId != nil {
            onAuthed()
        }
    }

    func printFile(_ path: String) {
        print("printFile \(path)")
        do {
            let string = try String(contentsOfFile: path, encoding: .utf8)
            print(string)
        } catch {
            print("error")
        }
    }

    var mqttClient: MQTTClient?
    func onAuthed() {
        let mqttConfig = MQTTConfig(clientId: clientId!, host: Config.AWS_IOT_MQTT_ENDPOINT, port: Int32(Config.AWS_IOT_MQTT_PORT), keepAlive: 60)
        mqttConfig.cleanSession = true
        mqttConfig.onConnectCallback = { returnCode in
            NSLog("Return Code is \(returnCode.description)")
        }
        mqttConfig.onMessageCallback = { mqttMessage in
            NSLog("MQTT Message received: payload=\(mqttMessage.payloadString)")
        }
        mqttConfig.onDisconnectCallback = { reasonCode in
            NSLog("Reason Code is \(reasonCode.description)")
        }

        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let key_file = folder.appendingPathComponent(self.KEY_FILE).path
        let crt_file = folder.appendingPathComponent(self.CRT_FILE).path
        mqttConfig.mqttClientCert = MQTTClientCert(certfile: crt_file, keyfile: key_file, keyfile_passwd: nil)

        let certFile = Bundle(for: type(of: self)).bundleURL.appendingPathComponent("aws.bundle").appendingPathComponent("rootCA.pem").path
        mqttConfig.mqttServerCert = MQTTServerCert(cafile: certFile, capath: nil)

        mqttConfig.mqttTlsOpts = MQTTTlsOpts(tls_insecure: false, cert_reqs: .ssl_verify_peer, tls_version: "tlsv1.2", ciphers: nil)

        mqttClient = MQTT.newConnection(mqttConfig)
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
        let data = ["auth_provider":authProvider, "auth_id":authId, "otp": otp]
        Alamofire.request(Config.AWS_API_GATEWAY_REGISTER_CLIENT, method: .post, parameters: data, encoding: JSONEncoding.default).responseJSON{ response in
            if let result = response.result.value {
                print(result)
                let data = result as! NSDictionary
                let status = data["status"] as! String
                if status == "exhausted" {
                    callback.onExhausted()
                    return
                }
                if status == "otp" {
                    callback.onCaptchaRequired()
                    return
                }
                if status == "ok" {
                    let id = data[Key.ID] as! String
                    let key = data["key"] as! String
                    let crt = data["crt"] as! String

                    Alamofire.request(key).responseString{ response in
                        let key = response.result.value!
                        Alamofire.request(crt).responseString{ response in
                            let crt = response.result.value!

                            let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let key_file = folder.appendingPathComponent(self.KEY_FILE).path
                            let crt_file = folder.appendingPathComponent(self.CRT_FILE).path

                            do {
                                try key.write(toFile: key_file, atomically: true, encoding: .ascii)
                                try crt.write(toFile: crt_file, atomically: true, encoding: .ascii)

                                self.clientId = id
                                UserDefaults.standard.set(id, forKey: Key.CLIENT_ID)

                                self.onAuthed()

                                callback.onDone()
                            } catch {
                                print("error")
                            }
                        }
                    }
                }
            }
        }
    }
}
