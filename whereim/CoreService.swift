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

protocol ChannelListChangedListener {
    func channelListChanged()
}

protocol MapDataReceiver {
    func onMateData(_ mate: Mate)
    func onEnchantmentData(_ enchantment: Enchantment)
    func onMarkerData(_ marker: Marker)
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

    var mqttConnected = false
    var mqttClient: MQTTClient?
    func onAuthed() {
        let mqttConfig = MQTTConfig(clientId: clientId!, host: Config.AWS_IOT_MQTT_ENDPOINT, port: Int32(Config.AWS_IOT_MQTT_PORT), keepAlive: 60)
        mqttConfig.cleanSession = true
        mqttConfig.onConnectCallback = { returnCode in
            if returnCode != .success {
                return
            }
            self.mqttConnected = true
            self.mqttOnConnected()
        }
        mqttConfig.onMessageCallback = { mqttMessage in
            NSLog("MQTT Message received: payload=\(mqttMessage.payloadString)")
            do {
                let data = try JSONSerialization.jsonObject(with: mqttMessage.payload, options: []) as! NSDictionary
                self.mqttOnMessage(mqttMessage.topic, data)
            } catch {
                print("error decoding message")
            }
        }
        mqttConfig.onDisconnectCallback = { reasonCode in
            self.mqttConnected = false
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

    func mqttOnConnected() {
        subscribe("client/\(clientId!)/+/get")
        publish("client/\(clientId!)/channel/sync", [Key.TS: 0])
    }

    func mqttOnMessage(_ topic: String, _ data: NSDictionary) {
        do {
            let clientChannelPattern = try NSRegularExpression(pattern: "^client/[a-f0-9]{32}/([^/]+)/get$", options: [])
            if let match = clientChannelPattern.firstMatch(in: topic, options: [], range: NSMakeRange(0, topic.characters.count)) {
                let t = (topic as NSString).substring(with: match.rangeAt(1))
                switch t {
                case "unicast":
                    mqttOnMessage(data["topic"] as! String, data["message"] as! NSDictionary)
                case "channel":
                    self.mqttClientChannelHandler(data)
                default:
                    break
                }
                return
            }
            let channelLocationPattern = try NSRegularExpression(pattern: "^channel/([a-f0-9]{32})/location/([^/]+)/get$", options: [])
            if let match = channelLocationPattern.firstMatch(in: topic, options: [], range: NSMakeRange(0, topic.characters.count)) {
                let channel_id = (topic as NSString).substring(with: match.rangeAt(1))
                mqttChannelLocationHandler(channel_id, data)
            }
            let channelDataPattern = try NSRegularExpression(pattern: "^channel/([a-f0-9]{32})/data/([^/]+)/get$", options: [])
            if let match = channelDataPattern.firstMatch(in: topic, options: [], range: NSMakeRange(0, topic.characters.count)) {
                let channel_id = (topic as NSString).substring(with: match.rangeAt(1))
                let category = (topic as NSString).substring(with: match.rangeAt(2))
                switch category {
                case "mate":
                    mqttChannelMateHandler(channel_id, data)
                case "message":
                    mqttChannelMessageHandler(channel_id, data, true)
                case "enchantment":
                    mqttChannelEnchantmentHandler(data)
                case "marker":
                    mqttChannelMarkerHandler(data)
                default:
                    break
                }
            }
        } catch {
            print("error in mqttOnMessage")
        }
    }

    func mqttChannelMateHandler(_ channel_id: String, _ data: NSDictionary) {
        let mate_id = data[Key.ID] as! String
        let mate = getChannelMate(channel_id, mate_id)

        mate.mate_name = data[Key.MATE_NAME] as? String ?? mate.mate_name
        mate.user_mate_name = data[Key.USER_MATE_NAME] as? String ?? mate.user_mate_name

        if let receivers = mapDataReceiver[channel_id]?.values {
            for receiver in receivers {
                receiver.onMateData(mate)
            }
        }
    }

    func mqttChannelMessageHandler(_ channel_id: String, _ data: NSDictionary, _ isPublic: Bool) {
    }


    var channelEnchantment = [String:[String:Enchantment]]()
    func mqttChannelEnchantmentHandler(_ data: NSDictionary) {
        let enchantment_id = data[Key.ID] as! String
        let channel_id = data[Key.CHANNEL] as! String

        if channelEnchantment[channel_id] == nil {
            channelEnchantment[channel_id] = [String:Enchantment]()
        }

        if channelEnchantment[channel_id]![enchantment_id] == nil {
            channelEnchantment[channel_id]![enchantment_id] = Enchantment()
        }

        let enchantment = channelEnchantment[channel_id]![enchantment_id]!
        enchantment.id = enchantment_id
        enchantment.channel_id = channel_id
        enchantment.name = data[Key.NAME] as? String ?? enchantment.name
        enchantment.latitude = data[Key.LATITUDE] as? Double ?? enchantment.latitude
        enchantment.longitude = data[Key.LONGITUDE] as? Double ?? enchantment.longitude
        enchantment.radius = data[Key.RADIUS] as? Double ?? enchantment.radius
        enchantment.isPublic = data[Key.PUBLIC] as? Bool ?? enchantment.isPublic
        enchantment.enable = data[Key.ENABLE] as? Bool ?? enchantment.enable

        if let receivers = mapDataReceiver[channel_id]?.values {
            for receiver in receivers {
                receiver.onEnchantmentData(enchantment)
            }
        }
    }

    var channelMarker = [String:[String:Marker]]()
    func mqttChannelMarkerHandler(_ data: NSDictionary) {
        let marker_id = data[Key.ID] as! String
        let channel_id = data[Key.CHANNEL] as! String

        if channelMarker[channel_id] == nil {
            channelMarker[channel_id] = [String:Marker]()
        }

        if channelMarker[channel_id]![marker_id] == nil {
            channelMarker[channel_id]![marker_id] = Marker()
        }

        let marker = channelMarker[channel_id]![marker_id]!
        marker.id = marker_id
        marker.channel_id = channel_id
        marker.name = data[Key.NAME] as? String ?? marker.name
        marker.latitude = data[Key.LATITUDE] as? Double ?? marker.latitude
        marker.longitude = data[Key.LONGITUDE] as? Double ?? marker.longitude
        if data[Key.ATTR] != nil {
            marker.attr = data[Key.ATTR] as? NSDictionary
        }
        marker.isPublic = data[Key.PUBLIC] as? Bool ?? marker.isPublic
        marker.enable = data[Key.ENABLE] as? Bool ?? marker.enable

        if let receivers = mapDataReceiver[channel_id]?.values {
            for receiver in receivers {
                receiver.onMarkerData(marker)
            }
        }
    }


    var channelMap = [String:Channel]()
    var channelList = [Channel]()
    func mqttClientChannelHandler(_ data: NSDictionary) {
        let channel_id = data[Key.CHANNEL] as! String
        var channel = channelMap[channel_id]
        if channel == nil {
            channel = Channel()
            channel!.id = channel_id
            channelMap[channel_id] = channel
            channelList.append(channel!)
        }
        channel!.channel_name = data["channel_name"] as! String? ?? channel!.channel_name
        channel!.user_channel_name = data["channel_name"] as! String? ?? channel!.user_channel_name
        channel!.mate_id = data[Key.MATE] as! String? ?? channel!.mate_id
        if let enable = data[Key.ENABLE] as! Bool? {
            channel!.enable = enable
        }

        subscribe("channel/\(channel_id)/data/+/get")

        publish("client/\(clientId!)/channel_data/sync", [Key.TS: 0, Key.CHANNEL: channel_id])

        for cb in channelListChangedListener {
            cb.value.channelListChanged()
        }
    }

    func mqttChannelLocationHandler(_ channel_id: String, _ data: NSDictionary) {
        let mate_id = data[Key.MATE] as! String
        let mate = getChannelMate(channel_id, mate_id)
        mate.channel_id = channel_id
        mate.latitude = data[Key.LATITUDE] as! Double? ?? mate.latitude
        mate.longitude = data[Key.LONGITUDE] as! Double? ?? mate.longitude
        mate.accuracy = data[Key.ACCURACY] as! Double? ?? mate.accuracy

        if let receivers = mapDataReceiver[channel_id]?.values {
            for receiver in receivers {
                receiver.onMateData(mate)
            }
        }
    }

    var channelMate = [String:[String:Mate]]()
    func getChannelMate(_ channel_id: String, _ mate_id: String) -> Mate {
        if channelMate[channel_id] == nil {
            channelMate[channel_id] = [String:Mate]()
        }
        if channelMate[channel_id]![mate_id] == nil {
            let mate = Mate()
            mate.id = mate_id
            channelMate[channel_id]![mate_id] = mate
        }
        return channelMate[channel_id]![mate_id]!
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
                                print("error writing key/crt")
                            }
                        }
                    }
                }
            }
        }
    }

    func getChannelList() -> [Channel] {
        return channelList
    }

    var acc = 0
    var channelListChangedListener = [Int:ChannelListChangedListener]()
    func addChannelListChangedListener(_ callback: ChannelListChangedListener) -> Int {
        acc += 1

        channelListChangedListener[acc] = callback
        callback.channelListChanged()
        return acc
    }

    func removeChannelListChangedListener(_ key: Int?) {
        if let k = key {
            channelListChangedListener.removeValue(forKey: k)
        }
    }

    var mapDataReceiver = [String:[Int:MapDataReceiver]]()
    var openedChannel = [String]()
    func openMap(channel: Channel, receiver: MapDataReceiver) -> Int? {
        if !mqttConnected {
            return nil
        }
        openedChannel.append(channel.id!)
        if mapDataReceiver[channel.id!] == nil {
            mapDataReceiver[channel.id!] = [Int:MapDataReceiver]()
        }
        acc += 1
        mapDataReceiver[channel.id!]![acc] = receiver

        subscribeChannelLocation(channel_id: channel.id!)

        if let markers = channelMarker[channel.id!] {
            for marker in markers.values {
                receiver.onMarkerData(marker)
            }
        }

        return acc
    }

    func closeMap(channel: Channel, key: Int) {
        unsubscribeChannelLocation(channel_id: channel.id!)
        if mapDataReceiver[channel.id!] == nil {
            return
        }
        mapDataReceiver[channel.id!]!.removeValue(forKey: key)
    }

    func subscribeChannelLocation(channel_id: String) {
        subscribe("channel/\(channel_id)/location/private/get")
    }

    func unsubscribeChannelLocation(channel_id: String) {
        unsubscribe("channel/\(channel_id)/location/private/get")
    }

    func publish(_ topic: String, _ message: NSDictionary) {
        do {
            let json = try JSONSerialization.data(withJSONObject: message, options: [])
            print("publish \(topic) \(String(data: json, encoding: .utf8)!)")
            mqttClient!.publish(json, topic: topic, qos: 1, retain: false)
        } catch {
            print("error in publish()")
        }
    }

    var subscribedTopics = [String]()
    func subscribe(_ topicFilter: String) {
        if subscribedTopics.index(of: topicFilter) != nil {
            return
        }
        mqttClient!.subscribe(topicFilter, qos: 1)
    }

    func unsubscribe(_ topicFilter: String) {
        mqttClient!.unsubscribe(topicFilter)
        if let index = subscribedTopics.index(of: topicFilter) {
            subscribedTopics.remove(at: index)
        }
    }
}
