//
//  CoreService.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import Alamofire
import CoreLocation
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

protocol ConnectionStatusCallback {
    func onConnectionStatusChanged(_ connected: Bool)
}

protocol Callback {
    func onCallback()
}

class CoreService: NSObject, CLLocationManagerDelegate {
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
            DispatchQueue.main.async {
                for listener in self.connectionStatusChangedListener {
                    listener.value.onConnectionStatusChanged(true)
                }
            }
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
            self.channelDataCheckedOut.removeAll()
            NSLog("Reason Code is \(reasonCode.description)")
            DispatchQueue.main.async {
                for listener in self.connectionStatusChangedListener {
                    listener.value.onConnectionStatusChanged(false)
                }
            }
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
                case "enchantment":
                    mqttChannelEnchantmentHandler(data)
                case "marker":
                    mqttChannelMarkerHandler(data)
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

        DispatchQueue.main.async {
            if let receivers = self.mapDataReceiver[channel_id] {
                for receiver in receivers {
                    receiver.value.onMateData(mate)
                }
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

        DispatchQueue.main.async {
            if let receivers = self.mapDataReceiver[channel_id] {
                for receiver in receivers {
                    receiver.value.onEnchantmentData(enchantment)
                }
            }
        }

        notifyChannelEnchantmentListChangedListeners(channel_id)
    }

    func getChannelEnchantment(_ channel_id: String) -> EnchantmentList {
        let list = EnchantmentList()
        if let enchantments = channelEnchantment[channel_id] {
            for enchantment in enchantments.values {
                if enchantment.isPublic == true {
                    list.public_list.append(enchantment)
                } else if enchantment.isPublic == false {
                    list.private_list.append(enchantment)
                }
            }
        }
        return list
    }

    func toggleEnchantmentEnabled(_ enchantment: Enchantment) {
        if enchantment.enable == nil {
            return
        }
        var topic: String?
        if enchantment.isPublic == true {
            topic = "channel/\(enchantment.channel_id!)/data/enchantment/put"
        } else if enchantment.isPublic == false {
            topic = "client/\(clientId!)/enchantment/put"
        }
        if topic != nil {
            publish(topic!, [Key.ID: enchantment.id!, Key.ENABLE: !enchantment.enable!])
            enchantment.enable = nil
        }

        notifyChannelEnchantmentListChangedListeners(enchantment.channel_id!)
    }

    var enchantmentListener = [String:[Int:Callback]]()
    func addEnchantmentListener(_ channel: Channel, _ okey: Int?, _ callback: Callback) -> Int {
        if enchantmentListener[channel.id!] == nil {
            enchantmentListener[channel.id!] = [Int:Callback]()
        }

        var key = okey
        if key == nil{
            acc_lock.sync {
                while enchantmentListener[channel.id!]![acc] != nil {
                    acc += 1
                }
                key = acc
            }
        }

        enchantmentListener[channel.id!]![key!] = callback

        return acc
    }

    func removeEnchantmentListener(_ channel: Channel, _ key: Int?) {
        if let k = key {
            if var listeners = enchantmentListener[channel.id!] {
                listeners.removeValue(forKey: k)
            }
        }
    }

    func notifyChannelEnchantmentListChangedListeners(_ channel_id: String) {
        DispatchQueue.main.async {
            if let listeners = self.enchantmentListener[channel_id] {
                for l in listeners.values {
                    l.onCallback()
                }
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

        DispatchQueue.main.async {
            if let receivers = self.mapDataReceiver[channel_id] {
                for receiver in receivers {
                    receiver.value.onMarkerData(marker)
                }
            }
        }
        notifyChannelMarkerListChangedListeners(channel_id)
    }

    func getChannelMarker(_ channel_id: String) -> MarkerList {
        let list = MarkerList()
        if let Markers = channelMarker[channel_id] {
            for marker in Markers.values {
                if marker.isPublic == true {
                    list.public_list.append(marker)
                } else if marker.isPublic == false {
                    list.private_list.append(marker)
                }
            }
        }
        return list
    }

    func toggleMarkerEnabled(_ marker: Marker) {
        if marker.enable == nil {
            return
        }
        var topic: String?
        if marker.isPublic == true {
            topic = "channel/\(marker.channel_id!)/data/marker/put"
        } else if marker.isPublic == false {
            topic = "client/\(clientId!)/marker/put"
        }
        if topic != nil {
            publish(topic!, [Key.ID: marker.id!, Key.ENABLE: !marker.enable!])
            marker.enable = nil
        }

        notifyChannelMarkerListChangedListeners(marker.channel_id!)
    }

    var markerListener = [String:[Int:Callback]]()
    func addMarkerListener(_ channel: Channel, _ okey: Int?, _ callback: Callback) -> Int {
        if markerListener[channel.id!] == nil {
            markerListener[channel.id!] = [Int:Callback]()
        }

        var key = okey
        if key == nil{
            acc_lock.sync {
                while markerListener[channel.id!]![acc] != nil {
                    acc += 1
                }
                key = acc
            }
        }

        markerListener[channel.id!]![key!] = callback

        return acc
    }

    func removeMarkerListener(_ channel: Channel, _ key: Int?) {
        if let k = key {
            if var listeners = markerListener[channel.id!] {
                listeners.removeValue(forKey: k)
            }
        }
    }

    func notifyChannelMarkerListChangedListeners(_ channel_id: String) {
        DispatchQueue.main.async {
            if let listeners = self.markerListener[channel_id] {
                for l in listeners {
                    l.value.onCallback()
                }
            }
        }
    }

    var channelDataCheckedOut = [String:Bool]()
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
        channel!.channel_name = data["channel_name"] as? String ?? channel!.channel_name
        channel!.user_channel_name = data["user_channel_name"] as? String ?? channel!.user_channel_name
        channel!.mate_id = data[Key.MATE] as! String? ?? channel!.mate_id
        if let enable = data[Key.ENABLE] as! Bool? {
            channel!.enable = enable
        }

        subscribe("channel/\(channel_id)/data/+/get")

        if channelDataCheckedOut[channel_id] == nil {
            channelDataCheckedOut[channel_id] = true
            publish("client/\(clientId!)/channel_data/sync", [Key.TS: 0, Key.CHANNEL: channel_id])
        }

        notifyChannelListChangedListeners()
    }

    func mqttChannelLocationHandler(_ channel_id: String, _ data: NSDictionary) {
        let mate_id = data[Key.MATE] as! String
        let mate = getChannelMate(channel_id, mate_id)
        mate.channel_id = channel_id
        mate.latitude = data[Key.LATITUDE] as! Double? ?? mate.latitude
        mate.longitude = data[Key.LONGITUDE] as! Double? ?? mate.longitude
        mate.accuracy = data[Key.ACCURACY] as! Double? ?? mate.accuracy

        DispatchQueue.main.async {
            if let receivers = self.mapDataReceiver[channel_id] {
                for receiver in receivers {
                    receiver.value.onMateData(mate)
                }
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

    var connectionStatusChangedListener = [Int:ConnectionStatusCallback]()
    func addConnectionStatusChangedListener(_ okey: Int?, _ callback: ConnectionStatusCallback) -> Int {
        var key = okey
        if key == nil {
            acc_lock.sync {
                while channelListChangedListener[acc] != nil {
                    acc += 1
                }
                key = acc
            }
        }

        connectionStatusChangedListener[key!] = callback
        DispatchQueue.main.async {
            callback.onConnectionStatusChanged(self.mqttConnected)
        }
        return key!
    }

    func removeConnectionStatusChangedListener(_ key: Int?) {
        if let k = key {
            connectionStatusChangedListener.removeValue(forKey: k)
        }
    }

    func getChannelList() -> [Channel] {
        return channelList
    }

    func getChannel(id: String) -> Channel? {
        return channelMap[id]
    }

    func toggleChannelEnabled(_ channel: Channel) {
        if channel.enable == nil {
            return
        }

        publish("client/\(clientId!)/channel/put", [Key.CHANNEL: channel.id!, Key.ENABLE: !channel.enable!])
        channel.enable = nil

        notifyChannelListChangedListeners()
    }

    let acc_lock = DispatchQueue(label: "acc")
    var acc = 0
    var channelListChangedListener = [Int:ChannelListChangedListener]()
    func addChannelListChangedListener(_ okey: Int?, _ callback: ChannelListChangedListener) -> Int {
        var key = okey
        if key == nil {
            acc_lock.sync {
                while channelListChangedListener[acc] != nil {
                    acc += 1
                }
                key = acc
            }
        }

        channelListChangedListener[key!] = callback

        DispatchQueue.main.async {
            callback.channelListChanged()
        }
        return key!
    }

    func removeChannelListChangedListener(_ key: Int?) {
        if let k = key {
            channelListChangedListener.removeValue(forKey: k)
        }
    }

    func notifyChannelListChangedListeners() {
        DispatchQueue.main.async {
            for cb in self.channelListChangedListener {
                cb.value.channelListChanged()
            }
            self._checkLocationService()
        }
    }

    var mapDataReceiver = [String:[Int:MapDataReceiver]]()
    var openedChannel = [String]()
    func openMap(_ channel: Channel, _ okey: Int?, _ receiver: MapDataReceiver) -> Int? {
        openedChannel.append(channel.id!)
        if mapDataReceiver[channel.id!] == nil {
            mapDataReceiver[channel.id!] = [Int:MapDataReceiver]()
        }

        var key = okey
        if key == nil {
            acc_lock.sync {
                while mapDataReceiver[channel.id!]![acc] != nil {
                    acc += 1
                }
                key = acc
            }
        }
        mapDataReceiver[channel.id!]![key!] = receiver

        subscribeChannelLocation(channel_id: channel.id!)

        DispatchQueue.main.async {
            if let enchantments = self.channelEnchantment[channel.id!] {
                for enchantment in enchantments.values {
                    receiver.onEnchantmentData(enchantment)
                }
            }

            if let markers = self.channelMarker[channel.id!] {
                for marker in markers.values {
                    receiver.onMarkerData(marker)
                }
            }
        }

        return key!
    }

    func closeMap(channel: Channel, key: Int) {
        unsubscribeChannelLocation(channel_id: channel.id!)
        if let index = openedChannel.index(of: channel.id!) {
            openedChannel.remove(at: index)
        }
        if mapDataReceiver[channel.id!] != nil {
            mapDataReceiver[channel.id!]!.removeValue(forKey: key)
        }
    }

    var isForeground = false
    func _checkLocationService() {
        var pending = false
        var enableCount = 0

        for channel in channelList {
            if channel.enable == nil {
                pending = true
                break
            } else if channel.enable == true {
                enableCount += 1
            }
        }

        if !pending {
            if enableCount > 0 {
                isForeground = true
                startLocationService()
            } else if enableCount == 0 {
                isForeground = false
                stopLocationService()
            }
        }
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


    let UPDATE_MIN_TIME = 10 // 10s
    let UPDATE_MIN_DISTANCE = 5 // 5m
    var locationServiceRunning = false
    let lm = CLLocationManager()
    func startLocationService() {
        if locationServiceRunning {
            return
        }
        locationServiceRunning = true
        lm.requestAlwaysAuthorization()
        lm.delegate = self
        lm.allowDeferredLocationUpdates(untilTraveled: CLLocationDistance(UPDATE_MIN_DISTANCE), timeout: TimeInterval(UPDATE_MIN_TIME))
        lm.startUpdatingLocation()
    }

    func stopLocationService() {
        lm.stopUpdatingLocation()
        locationServiceRunning = false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            processLocation(location: location)
        }
    }

    func processLocation(location: CLLocation) {
        print("processLocation", location.coordinate.latitude, location.coordinate.longitude)
        let data = [
            Key.LATITUDE: location.coordinate.latitude,
            Key.LONGITUDE: location.coordinate.longitude,
            Key.ACCURACY: location.horizontalAccuracy,
            Key.ALTITUDE: location.altitude,
            Key.TIME: UInt64(NSDate().timeIntervalSince1970*1000),
            Key.PROVIDER: "iOS"
        ] as NSMutableDictionary
        if location.course >= 0 {
            data.setValue(location.course, forKey: Key.BEARING)
        }
        if location.speed >= 0 {
            data.setValue(location.speed, forKey: Key.SPEED)
        }
        publish("client/\(clientId!)/location/put", data)
    }
}
