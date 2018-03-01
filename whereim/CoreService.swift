//
//  CoreService.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UserNotifications
import Alamofire
import CoreLocation
import GRDB
import Moscapsule
import Toast_Swift

protocol RegisterClientCallback {
    func onCaptchaRequired()
    func onExhausted()
    func onDone()
}

protocol ChannelListChangedListener {
    func channelListChanged()
}

protocol ChannelChangedListener {
    func channelChanged()
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

protocol ApiKeyCallback {
    func apiKey(_ key: String)
}

protocol MQTTCallback {
    func mqttOnConnected()
    func mqttOnDisconnected()
    func mqttOnReconnect()
    func mqttOnMessage(_ topic: String, _ data: [String: Any])
}

class MQTTSession {
    var mqttClient: MQTTClient?
    var mqttCallback: MQTTCallback
    var destroyed = false

    init(clientId: String, host: String, port: Int32, keepAlive: Int32, callback: MQTTCallback) {
        print("new connection")
        mqttCallback = callback

        let mqttConfig = MQTTConfig(clientId: clientId, host: host, port: port, keepAlive: keepAlive)

        mqttConfig.cleanSession = true
        mqttConfig.onConnectCallback = { returnCode in
            if returnCode != .success {
                return
            }
            self.mqttCallback.mqttOnConnected()
            Log.insert("onConnected")
        }
        mqttConfig.onMessageCallback = { mqttMessage in
            do {
                print("receive \(mqttMessage.payloadString!)")
                let data = try JSONSerialization.jsonObject(with: mqttMessage.payload!, options: []) as! [String: Any]
                self.mqttCallback.mqttOnMessage(mqttMessage.topic, data)
            } catch {
                print("error decoding message")
            }
        }
        mqttConfig.onDisconnectCallback = { reasonCode in
            self.mqttCallback.mqttOnDisconnected()

            if !self.destroyed {
                self.mqttCallback.mqttOnReconnect()
            }

            Log.insert("Disconnected: \(reasonCode.description) (\(reasonCode))")
        }

        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let key_file = folder.appendingPathComponent(Config.KEY_FILE).path
        let crt_file = folder.appendingPathComponent(Config.CRT_FILE).path
        mqttConfig.mqttClientCert = MQTTClientCert(certfile: crt_file, keyfile: key_file, keyfile_passwd: nil)

        let certFile = Bundle(for: type(of: self)).bundleURL.appendingPathComponent("aws.bundle").appendingPathComponent("rootCA.pem").path
        mqttConfig.mqttServerCert = MQTTServerCert(cafile: certFile, capath: nil)
        mqttConfig.mqttReconnOpts = nil
        mqttConfig.mqttTlsOpts = MQTTTlsOpts(tls_insecure: false, cert_reqs: .ssl_verify_peer, tls_version: "tlsv1.2", ciphers: nil)

        mqttClient = MQTT.newConnection(mqttConfig)
    }

    func destroy() {
        print("destroy")
        destroyed = true
        mqttClient?.disconnect()
    }
}

class CoreService: NSObject, CLLocationManagerDelegate, MQTTCallback {
    private static var service: CoreService?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    static func bind() -> CoreService{
        if service == nil {
            service = CoreService()
            service!.initialize()
        }
        return service!
    }

    private var isActiveDevice: Bool?
    private var otp: String?
    private var clientId: String?

    let DB_FILE = "whereim.sqlite"
    var dbConn: DatabaseQueue?

    var subscribedTopics = [String]()
    var channelMessageSync = [String:Bool]()
    var channelChannelSync = false
    var channelDataSync = [String:Bool]()
    var channelMap = [String:Channel]()
    var channelList = [Channel]()
    var channelMarker = [String:[String:Marker]]()
    var channelEnchantment = [String:[String:Enchantment]]()

    private var loaded = false

    func initialize(){
        if !loaded {
            loaded = true

            lm.requestAlwaysAuthorization()
            lm.delegate = self
            lm.allowsBackgroundLocationUpdates = true

            moscapsule_init()
        }
        subscribedTopics = [String]()
        channelMessageSync = [String:Bool]()
        channelChannelSync = false
        channelDataSync = [String:Bool]()
        channelMap = [String:Channel]()
        channelList = [Channel]()
        channelMarker = [String:[String:Marker]]()
        channelEnchantment = [String:[String:Enchantment]]()

        do {
            let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let db_file = folder.appendingPathComponent(DB_FILE).path
            dbConn = try DatabaseQueue(path: db_file)

            try dbConn!.inDatabase { db in
                let db_version = try Int.fetchOne(db, "PRAGMA user_version")!
                print("db_version", db_version)

                try Channel.migrate(db, db_version)
                print("Channel db migration finished")

                try Mate.migrate(db, db_version)
                print("Mate db migration finished")

                try Marker.migrate(db, db_version)
                print("Marker db migration finished")

                try Enchantment.migrate(db, db_version)
                print("Enchantment db migration finished")

                try Message.migrate(db, db_version)
                print("Message db migration finished")

                try Log.migrate(db, db_version)
                print("Log migration finished")

                print("All migration finished")

                try db.execute("PRAGMA user_version = \(Config.DB_VERSION)")
            }
        } catch {
            print("Error opening db \(error)")
        }

        clientId = UserDefaults.standard.string(forKey: Key.CLIENT_ID)

        if clientId != nil {
            onAuthed()
        }
    }

    func logout() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }

        if let t = timer {
            t.invalidate()
            timer = nil
        }
        if let session = mqttSession {
            session.destroy()
        }
        mqttSession = nil

        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let db_file = folder.appendingPathComponent(DB_FILE).path
        let key_file = folder.appendingPathComponent(Config.KEY_FILE).path
        let crt_file = folder.appendingPathComponent(Config.CRT_FILE).path
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: db_file) {
                try fileManager.removeItem(atPath: db_file)
            }
            if fileManager.fileExists(atPath: key_file) {
                try fileManager.removeItem(atPath: key_file)
            }
            if fileManager.fileExists(atPath: crt_file) {
                try fileManager.removeItem(atPath: crt_file)
            }
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }

        initialize()
    }

    var timer: Timer?
    var mqttConnected = false
    var mqttSession: MQTTSession?

    func resetMQTT() {
        if let session = mqttSession {
            session.destroy()
        }
        print("resetMQTT")
        mqttSession = MQTTSession(clientId: clientId!, host: Config.AWS_IOT_MQTT_ENDPOINT, port: Int32(Config.AWS_IOT_MQTT_PORT), keepAlive: 15, callback: self)
    }

    func onAuthed() {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            UIApplication.shared.registerForRemoteNotifications()
        }
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }

        subscribe("client/\(clientId!)/+/get")

        resetMQTT()

        for c in Channel.getAll() {
            channelList.append(c)
            channelMap[c.id!] = c
            clientChannelHandler(c)
        }
        for m in Mate.getAll() {
            if channelMate[m.channel_id!] == nil {
                channelMate[m.channel_id!] = [String:Mate]()
            }
            channelMate[m.channel_id!]![m.id!] = m
            channelMateHandler(m)
        }
        for m in Marker.getAll() {
            if channelMarker[m.channel_id!] == nil {
                channelMarker[m.channel_id!] = [String:Marker]()
            }
            channelMarker[m.channel_id!]![m.id!] = m
            channelMarkerHandler(m)
        }
        for e in Enchantment.getAll() {
            if channelEnchantment[e.channel_id!] == nil {
                channelEnchantment[e.channel_id!] = [String:Enchantment]()
            }
            channelEnchantment[e.channel_id!]![e.id!] = e
            channelEnchantmentHandler(e)
        }

        timer = Timer.scheduledTimer(timeInterval: TimeInterval(15), target: self, selector: #selector(checkMQTT), userInfo: nil, repeats: true)
    }

    @objc func checkMQTT() {
        DispatchQueue.main.async {
            if let client = self.mqttSession?.mqttClient {
                if !client.isConnected {
                    Log.insert("reconnect")
                    self.resetMQTT()
                }
            }
        }
    }

    func mqttOnConnected() {
        print("mqttOnConnected() \(clientId!)")
        self.mqttConnected = true
        DispatchQueue.main.async {
            for listener in self.connectionStatusChangedListener {
                listener.value.onConnectionStatusChanged(true)
            }
        }

        sendPushToken()

        publish("client/\(clientId!)/channel/sync", [Key.TS: getTS()])

        for topic in subscribedTopics {
            mqttSession?.mqttClient?.subscribe(topic, qos: 1)
        }
        for channel in channelList {
            syncChannelData(channel.id!)
            syncChannelMessage(channel.id!)
        }

        if let link = pending_link {
            pending_link = nil
            processLink(link)
        }
    }

    func mqttOnDisconnected() {
        print("mqttOnDisconnected()")
        self.mqttConnected = false
        self.channelDataSync.removeAll()
        self.channelMessageSync.removeAll()
        DispatchQueue.main.async {
            for listener in self.connectionStatusChangedListener {
                listener.value.onConnectionStatusChanged(false)
            }
        }
    }

    func mqttOnReconnect(){
        print("mqttOnReconnect()")
        DispatchQueue.main.async {
            self.resetMQTT()
        }
    }

    func mqttOnMessage(_ topic: String, _ data: [String: Any]) {
        do {
            let clientChannelPattern = try NSRegularExpression(pattern: "^client/[a-f0-9]{32}/([^/]+)/get$", options: [])
            let nstopic = topic as NSString
            if let match = clientChannelPattern.firstMatch(in: topic, options: [], range: NSMakeRange(0, nstopic.length)) {
                let t = nstopic.substring(with: match.range(at: 1))
                switch t {
                case "unicast":
                    mqttOnMessage(data["topic"] as! String, data["message"] as! [String: Any])
                case "channel":
                    mqttClientChannelHandler(data)
                case "enchantment":
                    mqttChannelEnchantmentHandler(data)
                case "marker":
                    mqttChannelMarkerHandler(data)
                case "profile":
                    mqttClientProfileHandler(data)
                case "toast":
                    mqttToastHandler(data)
                default:
                    break
                }
                return
            }
            let channelLocationPattern = try NSRegularExpression(pattern: "^channel/([a-f0-9]{32})/map/([^/]+)/get$", options: [])
            if let match = channelLocationPattern.firstMatch(in: topic, options: [], range: NSMakeRange(0, nstopic.length)) {
                let channel_id = nstopic.substring(with: match.range(at: 1))
                mqttChannelLocationHandler(channel_id, data)
                return
            }
            let channelDataPattern = try NSRegularExpression(pattern: "^channel/([a-f0-9]{32})/data/([^/]+)/get$", options: [])
            if let match = channelDataPattern.firstMatch(in: topic, options: [], range: NSMakeRange(0, nstopic.length)) {
                let channel_id = nstopic.substring(with: match.range(at: 1))
                let category = nstopic.substring(with: match.range(at: 2))
                switch category {
                case "mate":
                    mqttChannelMateHandler(channel_id, data)
                case "message":
                    mqttChannelMessageHandler(channel_id, data)
                case "enchantment":
                    mqttChannelEnchantmentHandler(data)
                case "marker":
                    mqttChannelMarkerHandler(data)
                default:
                    break
                }
                return
            }
            let systemKeyPattern = try NSRegularExpression(pattern: "^system/key/get$", options: [])
            if let _ = systemKeyPattern.firstMatch(in: topic, options: [], range: NSMakeRange(0, nstopic.length)) {
                mqttSystemKeyHandler(data)
                return
            }
        } catch {
            print("error in mqttOnMessage")
        }
    }

    func mqttToastHandler(_ data: [String: Any]) {
        let key = data["key"] as! String
        let args = data["args"] as! [String]
        var message: String?
        switch key {
        case "limit_active_channel":
            let limit = args[0]
            message = String(format: "message_limit_active_channel".localized, limit)
        case "limit_enabled_channel":
            let limit = args[0]
            message = String(format: "message_limit_enabled_channel".localized, limit)
        default:
            break
        }
        if let m = message {
            if let vc = currentViewController {
                DispatchQueue.main.async {
                    vc.view!.makeToast(m)
                }
            }
        }
    }

    private var currentViewController: UIViewController?
    func setViewController(_ viewController: UIViewController?) {
        currentViewController = viewController
        if currentViewController != nil {
            requestActiveClient()
        }
    }

    var pendingPOI: POI?
    private var pending_link: String?
    func processLink(_ link: String) {
        do {
            let pattern_here = try NSRegularExpression(pattern: "^here/(-?[0-9.]+)/(-?[0-9.]+)(?:/(.*))?$", options: [])
            let pattern_open_in_channel = try NSRegularExpression(pattern: "^open_in_channel/(.*)$", options: [])
            let pattern_channel = try NSRegularExpression(pattern: "^channel/([a-f0-9]{32})$", options: [])

            let nslink = link as NSString
            if let match = pattern_here.firstMatch(in: link, options: [], range: NSMakeRange(0, nslink.length)) {
                guard let lat = Double(nslink.substring(with: match.range(at: 1))) else {
                    return
                }
                guard let lng = Double(nslink.substring(with: match.range(at: 2))) else {
                    return
                }
                let name = (link as NSString).substring(with: match.range(at: 3))
                DispatchQueue.main.async {
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let pvc = sb.instantiateViewController(withIdentifier: "location_viewer") as! PoiViewerController
                    let poi = POI()
                    poi.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    poi.name = name
                    pvc.poi = poi
                    self.appDelegate.window?.rootViewController = pvc;
                }
                return
            }

            if !mqttConnected {
                pending_link = link
                return
            }
            if let match = pattern_channel.firstMatch(in: link, options: [], range: NSMakeRange(0, nslink.length)) {
                let channel_id = nslink.substring(with: match.range(at: 1))
                DispatchQueue.main.async {
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let startupVC = sb.instantiateViewController(withIdentifier: "startup") as! UINavigationController
                    self.appDelegate.window?.rootViewController = startupVC;
                    _ = DialogJoinChannel(startupVC, channel_id)
                }
            }
            if let match = pattern_open_in_channel.firstMatch(in: link, options: [], range: NSMakeRange(0, nslink.length)) {
                let sublink = nslink.substring(with: match.range(at: 1))
                let nssublink = sublink as NSString
                if let m = pattern_here.firstMatch(in: sublink, options: [], range: NSMakeRange(0, nssublink.length)) {
                    guard let lat = Double(nssublink.substring(with: m.range(at: 1))) else {
                        return
                    }
                    guard let lng = Double(nssublink.substring(with: m.range(at: 2))) else {
                        return
                    }
                    let name = nssublink.substring(with: m.range(at: 3))
                    DispatchQueue.main.async {
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let startupVC = sb.instantiateViewController(withIdentifier: "startup") as! UINavigationController
                        let poi = POI()
                        poi.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        poi.name = name
                        self.pendingPOI = poi
                        self.appDelegate.window?.rootViewController = startupVC;
                    }
                }
            }
        } catch {
            print("Error in processLink")
        }
    }

    func setActive() {
        publish("client/\(clientId!)/profile/put", [Key.ACTIVE:clientId!])
    }

    var pendingPushToken: String?
    func setPushToken(_ token: String) {
//        let oldToken = UserDefaults.standard.string(forKey: "apns_token")
//        if oldToken != token {
            pendingPushToken = token
            sendPushToken()
//        }
    }

    func sendPushToken() {
        if clientId == nil {
            return
        }
        if let token = pendingPushToken {
            publish("client/\(clientId!)/profile/put", ["apns_token":token])
        }
    }

    private var requestActiveDevice = false
    func mqttClientProfileHandler(_ data: [String: Any]) {
        if let token = data["apns_token"] as? String {
            if token == pendingPushToken {
                pendingPushToken = nil
            }
            UserDefaults.standard.set(token, forKey: "apns_token")
        }

        if let activeDevice = data[Key.ACTIVE] {
            let active = (activeDevice as? String) == clientId!
            if (isActiveDevice == nil || active != isActiveDevice) && !active {
                requestActiveDevice = true
                requestActiveClient()
            }
            isActiveDevice = active
            _checkLocationService()
        }
    }

    private func requestActiveClient() {
        if !requestActiveDevice {
            return
        }
        requestActiveDevice = false
        if let vc = currentViewController {
            DispatchQueue.main.async {
                _ = DialogRequestActiveDevice(vc)
            }
        }
    }

    func mqttChannelMateHandler(_ channel_id: String, _ data: [String: Any]) {
        let mate_id = data[Key.ID] as! String
        let mate = getChannelMate(channel_id, mate_id)

        mate.mate_name = data[Key.MATE_NAME] as? String ?? mate.mate_name
        mate.user_mate_name = data[Key.USER_MATE_NAME] as? String ?? mate.user_mate_name
        mate.deleted = data[Key.DELETED] as? Bool ?? mate.deleted

        if let ts = data[Key.TS] {
            setTS(channel_id, ts as! UInt64)
        }

        dbConn!.inDatabase { db in
            do {
                try mate.save(db)
            } catch {
                print("Error saving mate \(error)")
            }
        }

        channelMateHandler(mate)
    }

    func channelMateHandler(_ mate: Mate) {
        DispatchQueue.main.async {
            if let receivers = self.mapDataReceiver[mate.channel_id!] {
                for receiver in receivers {
                    receiver.value.onMateData(mate)
                }
            }
        }

        notifyMateListeners(mate.channel_id!)
    }

    var mateListener = [String:[Int:Callback]]()
    func addMateListener(_ channel: Channel, _ okey: Int?, _ callback: Callback) -> Int {
        if mateListener[channel.id!] == nil {
            mateListener[channel.id!] = [Int:Callback]()
        }

        var key = okey
        if key == nil{
            acc_lock.sync {
                while mateListener[channel.id!]![acc] != nil {
                    acc += 1
                }
                key = acc
            }
        }

        mateListener[channel.id!]![key!] = callback
        return key!
    }

    func removeMateListener(_ channel: Channel, _ key: Int?) {
        if let k = key {
            if mateListener[channel.id!] != nil {
                mateListener[channel.id!]!.removeValue(forKey: k)
            }
        }
    }

    func notifyMateListeners(_ channel_id: String) {
        DispatchQueue.main.async {
            if let listeners = self.mateListener[channel_id] {
                for l in listeners.values {
                    l.onCallback()
                }
            }
        }
    }

    func mqttChannelMessageHandler(_ channel_id: String, _ data: [String: Any]) {
        let m = Message(data)

        dbConn!.inDatabase { db in
            do {
                try m.save(db)
            } catch {
                print("Error saving message \(error)")
            }
        }

        set(channel_id: channel_id, unread: true)

        notifyChannelMessageListeners(channel_id)
    }

    func toggleRadiusEnabled(_ channel: Channel) {
        if channel.enable_radius == nil {
            return
        }
        publish("client/\(clientId!)/channel/put", [Key.CHANNEL: channel.id!, Key.ENABLE_RADIUS: !channel.enable_radius!])
        channel.enable_radius = nil

        notifyChannelChangedListeners(channel.id!)
    }

    func mqttChannelEnchantmentHandler(_ data: [String:Any]) {
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
        enchantment.radius = data[Key.RADIUS] as? Int ?? enchantment.radius
        enchantment.isPublic = data[Key.PUBLIC] as? Bool ?? enchantment.isPublic
        enchantment.enabled = data[Key.ENABLED] as? Bool ?? enchantment.enabled
        enchantment.deleted = data[Key.DELETED] as? Bool ?? enchantment.deleted

        if let ts = data[Key.TS] {
            setTS(channel_id, ts as! UInt64)
        }

        dbConn!.inDatabase { db in
            do {
                try enchantment.save(db)
            } catch {
                print("Error saving enchantment \(error)")
            }
        }

        channelEnchantmentHandler(enchantment)
    }

    func channelEnchantmentHandler(_ enchantment: Enchantment) {
        DispatchQueue.main.async {
            if let receivers = self.mapDataReceiver[enchantment.channel_id!] {
                for receiver in receivers {
                    receiver.value.onEnchantmentData(enchantment)
                }
            }
        }

        if enchantment.deleted {
            channelEnchantment[enchantment.channel_id!]!.removeValue(forKey: enchantment.id!)
            dbConn!.inDatabase { db in
                do {
                    try enchantment.delete(db)
                } catch {
                    print("Error deleting enchantment \(error)")
                }
            }
        }

        notifyChannelEnchantmentListChangedListeners(enchantment.channel_id!)
    }

    func getChannelEnchantment(_ channel_id: String, _ filterKeyword: String?) -> EnchantmentList {
        let list = EnchantmentList()
        if let enchantments = channelEnchantment[channel_id] {
            for enchantment in enchantments.values {
                var matched = true
                if let f = filterKeyword {
                    matched = false
                    if enchantment.name?.localizedCaseInsensitiveContains(f) == true {
                        matched = true
                    }
                }
                if !matched {
                    continue
                }
                if enchantment.isPublic == true {
                    list.public_list.append(enchantment)
                } else if enchantment.isPublic == false {
                    list.private_list.append(enchantment)
                }
            }
        }
        list.public_list.sort(by: {$0.name!.localizedCompare($1.name!) == .orderedAscending})
        list.private_list.sort(by: {$0.name!.localizedCompare($1.name!) == .orderedAscending})
        return list
    }

    func set(enchantment: Enchantment) {
        var data = [String:Any]()
        if enchantment.id == nil {
            data[Key.CHANNEL] = enchantment.channel_id!
            data[Key.ENABLED] = true
        } else {
            data[Key.ID] = enchantment.id!
        }
        data[Key.NAME] = enchantment.name!
        data[Key.LATITUDE] = enchantment.latitude!
        data[Key.LONGITUDE] = enchantment.longitude!
        data[Key.RADIUS] = enchantment.radius!

        if enchantment.isPublic == true {
            publish("channel/\(enchantment.channel_id!)/data/enchantment/put", data)
        } else {
            publish("client/\(clientId!)/enchantment/put", data)
        }
    }

    func toggleEnchantmentEnabled(_ enchantment: Enchantment) {
        if enchantment.enabled == nil {
            return
        }
        var topic: String?
        if enchantment.isPublic == true {
            topic = "channel/\(enchantment.channel_id!)/data/enchantment/put"
        } else if enchantment.isPublic == false {
            topic = "client/\(clientId!)/enchantment/put"
        }
        if topic != nil {
            publish(topic!, [Key.ID: enchantment.id!, Key.ENABLED: !enchantment.enabled!])
            enchantment.enabled = nil
        }

        notifyChannelEnchantmentListChangedListeners(enchantment.channel_id!)
    }

    func deleteEnchantment(_ enchantment: Enchantment) {
        let data = [
            Key.ID: enchantment.id!,
            Key.DELETED: true
            ] as [String: Any]

        if enchantment.isPublic == true {
            publish("channel/\(enchantment.channel_id!)/data/enchantment/put", data)
        } else if enchantment.isPublic == false {
            publish("client/\(clientId!)/enchantment/put", data)
        }
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

        return key!
    }

    func removeEnchantmentListener(_ channel: Channel, _ key: Int?) {
        if let k = key {
            if enchantmentListener[channel.id!] != nil {
                enchantmentListener[channel.id!]!.removeValue(forKey: k)
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

    func getChannelMarker(_ channel_id: String, _ marker_id: String) -> Marker? {
        return channelMarker[channel_id]?[marker_id]
    }

    func mqttChannelMarkerHandler(_ data: [String:Any]) {
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
            marker.attr = data[Key.ATTR] as? [String: Any]
        }
        marker.isPublic = data[Key.PUBLIC] as? Bool ?? marker.isPublic
        marker.enabled = data[Key.ENABLED] as? Bool ?? marker.enabled
        marker.deleted = data[Key.DELETED] as? Bool ?? marker.deleted

        if let ts = data[Key.TS] {
            setTS(channel_id, ts as! UInt64)
        }

        dbConn!.inDatabase { db in
            do {
                try marker.save(db)
            } catch {
                print("Error saving marker \(error)")
            }
        }

        channelMarkerHandler(marker)
    }

    func channelMarkerHandler(_ marker: Marker) {
        DispatchQueue.main.async {
            if let receivers = self.mapDataReceiver[marker.channel_id!] {
                for receiver in receivers {
                    receiver.value.onMarkerData(marker)
                }
            }
        }

        if marker.deleted {
            channelMarker[marker.channel_id!]!.removeValue(forKey: marker.id!)
            dbConn!.inDatabase { db in
                do {
                    try marker.delete(db)
                } catch {
                    print("Error deleting marker \(error)")
                }
            }
        }

        notifyChannelMarkerListChangedListeners(marker.channel_id!)
    }

    func getChannelMarker(_ channel_id: String, _ filter: String?) -> MarkerList {
        let list = MarkerList()
        if let Markers = channelMarker[channel_id] {
            for marker in Markers.values {
                var matched = true
                if let f = filter {
                    matched = false
                    if marker.name?.localizedCaseInsensitiveContains(f) == true {
                        matched = true
                    }
                }
                if !matched {
                    continue
                }
                if marker.isPublic == true {
                    list.public_list.append(marker)
                } else if marker.isPublic == false {
                    list.private_list.append(marker)
                }
            }
        }
        list.public_list.sort(by: {$0.name!.localizedCompare($1.name!) == .orderedAscending})
        list.private_list.sort(by: {$0.name!.localizedCompare($1.name!) == .orderedAscending})
        return list
    }

    func set(marker: Marker) {
        var data = [String:Any]()
        if marker.id == nil {
            data[Key.CHANNEL] = marker.channel_id!
            data[Key.ENABLED] = true
        } else {
            data[Key.ID] = marker.id!
        }
        data[Key.NAME] = marker.name!
        data[Key.LATITUDE] = marker.latitude!
        data[Key.LONGITUDE] = marker.longitude!
        data[Key.ATTR] = marker.attr!

        if marker.isPublic == true {
            publish("channel/\(marker.channel_id!)/data/marker/put", data)
        } else {
            publish("client/\(clientId!)/marker/put", data)
        }
    }

    func toggleMarkerEnabled(_ marker: Marker) {
        if marker.enabled == nil {
            return
        }
        var topic: String?
        if marker.isPublic == true {
            topic = "channel/\(marker.channel_id!)/data/marker/put"
        } else if marker.isPublic == false {
            topic = "client/\(clientId!)/marker/put"
        }
        if topic != nil {
            publish(topic!, [Key.ID: marker.id!, Key.ENABLED: !marker.enabled!])
            marker.enabled = nil
        }

        notifyChannelMarkerListChangedListeners(marker.channel_id!)
    }

    func deleteMarker(_ marker: Marker) {
        let data = [
            Key.ID: marker.id!,
            Key.DELETED: true
        ] as [String: Any]

        if marker.isPublic == true {
            publish("channel/\(marker.channel_id!)/data/marker/put", data)
        } else if marker.isPublic == false {
            publish("client/\(clientId!)/marker/put", data)
        }
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

        return key!
    }

    func removeMarkerListener(_ channel: Channel, _ key: Int?) {
        if let k = key {
            if markerListener[channel.id!] != nil {
                markerListener[channel.id!]!.removeValue(forKey: k)
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

    func getMessages(_ channel_id: String) -> BundledMessages {
        return Message.getMessages(channel_id)
    }

    func sendMessage(_ channel_id: String, _ text: String, _ location: CLLocationCoordinate2D?) {
        var data = [String:Any]()
        data[Key.MESSAGE] = text
        if let ll = location {
            data[Key.TYPE] = "rich"
            data[Key.LATITUDE] = ll.latitude
            data[Key.LONGITUDE] = ll.longitude
        }
        publish("channel/\(channel_id)/data/message/put", data)
    }

    func sendNotification(_ channel_id: String, _ type: String) {
        publish("channel/\(channel_id)/data/message/put", [Key.TYPE: type])
    }

    func requestMessage(_ channel: Channel, before: Int64?, after: Int64?) {
        var data = [String:Any]()
        data[Key.CHANNEL] = channel.id!
        if let b = before {
            data["before"] = b
        }
        if let a = after {
            data["after"] = a
        }
        self.publish("client/\(self.clientId!)/message/sync", data)
    }

    var messageListener = [String:[Int:Callback]]()
    func addMessageListener(_ channel: Channel, _ okey: Int?, _ callback: Callback) -> Int {
        if messageListener[channel.id!] == nil {
            messageListener[channel.id!] = [Int:Callback]()
        }

        var key = okey
        if key == nil{
            acc_lock.sync {
                while messageListener[channel.id!]![acc] != nil {
                    acc += 1
                }
                key = acc
            }
        }

        messageListener[channel.id!]![key!] = callback

        return key!
    }

    func removeMessageListener(_ channel: Channel, _ key: Int?) {
        if let k = key {
            if messageListener[channel.id!] != nil {
                messageListener[channel.id!]!.removeValue(forKey: k)
            }
        }
    }

    func hasMessageListener(channel_id: String) -> Bool {
        if messageListener[channel_id] != nil {
            if messageListener[channel_id]!.count > 0 {
                return true
            }
        }
        return false
    }

    func notifyChannelMessageListeners(_ channel_id: String) {
        DispatchQueue.main.async {
            if let listeners = self.messageListener[channel_id] {
                for l in listeners {
                    l.value.onCallback()
                }
            }
        }
    }

    func mqttClientChannelHandler(_ data: [String:Any]) {
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
        channel!.mate_id = data[Key.MATE] as? String ?? channel!.mate_id
        channel!.deleted = data[Key.DELETED] as? Bool ?? channel!.deleted
        channel!.enable_radius = data[Key.ENABLE_RADIUS] as? Bool ?? channel!.enable_radius
        channel!.radius = data[Key.RADIUS] as? Int ?? channel!.radius
        channel!.active = data[Key.ACTIVE] as? Bool ?? channel!.active
        channel!.enabled = data[Key.ENABLED] as? Bool ?? channel!.enabled
        channel!.is_public = data[Key.PUBLIC] as? Bool ?? channel!.is_public

        if let ts = data[Key.TS] {
            setTS(ts as! UInt64)
        }

        dbConn!.inDatabase { db in
            do {
                try channel!.save(db)
            } catch {
                print("Error saving channel \(error)")
            }
        }

        clientChannelHandler(channel!)
    }

    func clientChannelHandler(_ channel: Channel) {
        let channel_id = channel.id!

        if channel.deleted {
            unsubscribe("channel/\(channel_id)/data/+/get")
            channelMap.removeValue(forKey: channel.id!)
            if let idx = channelList.index(where: { $0.id! == channel.id! }) {
                channelList.remove(at: idx)
            }
            clearTS(channel.id!)
            dbConn!.inDatabase { db in
                do {
                    try channel.delete(db)
                } catch {
                    print("Error deleting channel \(error)")
                }
            }
        } else {
            if channel.enabled == true {
                if channel.is_public {
                    subscribe("channel/\(channel_id)/data/+/get")
                } else {
                    unsubscribe("channel/\(channel_id)/data/+/get")
                }

                syncChannelData(channel_id)
                syncChannelMessage(channel_id)
            }
            if channel.enabled == false {
                unsubscribe("channel/\(channel_id)/data/+/get")
            }
        }

        notifyChannelChangedListeners(channel.id!)
        notifyChannelListChangedListeners()
        updateBadge()
    }

    func set(channel_id: String, unread: Bool) {
        if let channel = channelMap[channel_id] {
            channel.unread = unread
            dbConn!.inDatabase { db in
                do {
                    try channel.save(db)
                } catch {
                    print("Error saving channel \(error)")
                }
            }
            notifyChannelListChangedListeners()
            updateBadge()
        }
    }

    func updateBadge() {
        var unread = 0
        for channel in channelList {
            if channel.enabled==true && channel.unread {
                unread += 1
            }
        }
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = unread
        }
    }

    func syncChannelData(_ channel_id: String) {
        if channelDataSync[channel_id] == nil {
            channelDataSync[channel_id] = true
            publish("client/\(clientId!)/channel_data/sync", [Key.TS: getTS(channel_id), Key.CHANNEL: channel_id])
        }
    }

    func syncChannelMessage(_ channel_id: String) {
        if channelMessageSync[channel_id] == nil {
            channelMessageSync[channel_id] = true
            DispatchQueue.main.async {
                let data = Message.getMessages(channel_id)
                self.publish("client/\(self.clientId!)/message/sync", [Key.CHANNEL: channel_id, "after": data.lastId])
            }
        }
    }

    func mqttChannelLocationHandler(_ channel_id: String, _ data: [String:Any]) {
        let mate_id = data[Key.MATE] as! String
        let mate = getChannelMate(channel_id, mate_id)
        mate.channel_id = channel_id
        if let lat = data[Key.LATITUDE] {
            mate.latitude = lat as? Double
        }
        if let lng = data[Key.LONGITUDE] {
            mate.longitude = lng as? Double
        }
        if let acc = data[Key.ACCURACY] {
            mate.accuracy = acc as? Double
        }
        if let _ = data[Key.STALE] {
            mate.stale = true
        } else {
            mate.stale = false
        }
        DispatchQueue.main.async {
            if let receivers = self.mapDataReceiver[channel_id] {
                for receiver in receivers {
                    receiver.value.onMateData(mate)
                }
            }
            self.notifyMateListeners(channel_id)
        }
    }

    var channelMate = [String:[String:Mate]]()
    func getChannelMate(_ channel_id: String, filter: String?) -> [Mate] {
        var list = [Mate]()
        if channelMate[channel_id] != nil {
            for mate in channelMate[channel_id]!.values {
                var matched = true
                if let f = filter {
                    matched = false
                    if mate.mate_name?.localizedCaseInsensitiveContains(f) == true {
                        matched = true
                    }
                    if mate.user_mate_name?.localizedCaseInsensitiveContains(f) == true {
                        matched = true
                    }
                }
                if !matched {
                    continue
                }
                if !mate.deleted {
                    list.append(mate)
                }
            }
        }
        list.sort(by: {$0.getDisplayName().localizedCompare($1.getDisplayName()) == .orderedAscending})
        return list
    }

    func getChannelMate(_ channel_id: String, _ mate_id: String) -> Mate {
        if channelMate[channel_id] == nil {
            channelMate[channel_id] = [String:Mate]()
        }
        if channelMate[channel_id]![mate_id] == nil {
            let mate = Mate()
            mate.id = mate_id
            mate.channel_id = channel_id
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

    func register_client(authProvider: String, authToken: String, authId: String, name: String, callback: RegisterClientCallback) {
        print(authProvider)
        print(authId)
        print(authToken)
        print(name)
        var data = ["auth_provider":authProvider, "auth_token": authToken, "auth_id":authId, "platform":"ios"]
        if otp != nil {
            data["otp"] = otp!
        }
        Alamofire.request(Config.AWS_API_GATEWAY_REGISTER_CLIENT, method: .post, parameters: data, encoding: JSONEncoding.default).responseJSON{ response in
            if let result = response.result.value {
                print(result)
                let data = result as! [String:Any]
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
                            let key_file = folder.appendingPathComponent(Config.KEY_FILE).path
                            let crt_file = folder.appendingPathComponent(Config.CRT_FILE).path

                            do {
                                try key.write(toFile: key_file, atomically: true, encoding: .ascii)
                                try crt.write(toFile: crt_file, atomically: true, encoding: .ascii)

                                self.clientId = id
                                UserDefaults.standard.set(id, forKey: Key.CLIENT_ID)
                                UserDefaults.standard.set(name, forKey: Key.NAME)

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
        var list = [Channel]()
        for c in channelList {
            list.append(c)
        }
        list.sort(by: {
            if $0.enabled == $1.enabled {
                return $0.getName().localizedCompare($1.getName()) == .orderedAscending
            }
            let e0 = $0.enabled == true ? 0 : 1
            let e1 = $1.enabled == true ? 0 : 1
            return e0 < e1
        })
        return list
    }

    func getChannel(id: String) -> Channel? {
        return channelMap[id]
    }

    func toggleChannelActive(_ vc: UIViewController, _ channel: Channel) {
        if channel.active == nil {
            return
        }

        let wasActive = channel.active!

        publish("client/\(clientId!)/channel/put", [Key.CHANNEL: channel.id!, Key.ACTIVE: !channel.active!])
        channel.active = nil

        if wasActive == false {
            _ = DialogSendSharingNotification(vc, channel.id!)
        }

        notifyChannelListChangedListeners()
    }

    func toggleChannelEnabled(_ channel: Channel) {
        if channel.enabled == nil {
            return
        }

        publish("client/\(clientId!)/channel/put", [Key.CHANNEL: channel.id!, Key.ENABLED: !channel.enabled!])
        channel.enabled = nil
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

    var channelChangedListener = [String:[Int:ChannelChangedListener]]()
    func addChannelChangedListener(_ channel: Channel, _ okey: Int?, _ callback: ChannelChangedListener) -> Int {
        if channelChangedListener[channel.id!] == nil {
            channelChangedListener[channel.id!] = [Int:ChannelChangedListener]()
        }

        var key = okey
        if key == nil{
            acc_lock.sync {
                while channelChangedListener[channel.id!]![acc] != nil {
                    acc += 1
                }
                key = acc
            }
        }

        channelChangedListener[channel.id!]![key!] = callback

        return key!
    }

    func removeChannelChangedListener(_ channel: Channel, _ key: Int?) {
        if let k = key {
            if channelChangedListener[channel.id!] != nil {
                channelChangedListener[channel.id!]!.removeValue(forKey: k)
            }
        }
    }

    func notifyChannelChangedListeners(_ channel_id: String) {
        DispatchQueue.main.async {
            if let listeners = self.channelChangedListener[channel_id] {
                for l in listeners.values {
                    l.channelChanged()
                }
            }
        }
    }

    func createChannel(channel_name: String, mate_name: String) {
        publish("channel/create", [Key.CHANNEL_NAME: channel_name, Key.MATE_NAME: mate_name])
    }

    func joinChannel(channel_id: String, channel_alias: String, mate_name: String) {
        publish("channel/\(channel_id)/join", [Key.CHANNEL_NAME: channel_alias, Key.MATE_NAME: mate_name])
    }

    func editChannel(_ channel: Channel, _ channel_name: String, _ user_channel_name: String) {
        publish("client/\(clientId!)/channel/put", [Key.CHANNEL: channel.id!, Key.CHANNEL_NAME: channel_name, Key.USER_CHANNEL_NAME: user_channel_name])
    }

    func deleteChannel(_ channel: Channel) {
        publish("client/\(clientId!)/channel/put", [Key.CHANNEL: channel.id!, Key.DELETED: true])
    }

    func setSelfRadius(_ channel: Channel, _ radius: Int) {
        publish("client/\(clientId!)/channel/put", [Key.CHANNEL: channel.id!, Key.RADIUS: radius])
    }

    func editSelf(_ mate: Mate, _ mate_name: String) {
        publish("channel/\(mate.channel_id!)/data/mate/put", [Key.ID: mate.id!, Key.MATE_NAME: mate_name])
    }

    func editMate(_ mate: Mate, _ user_mate_name: String) {
        publish("channel/\(mate.channel_id!)/data/mate/put", [Key.ID: mate.id!, Key.USER_MATE_NAME: user_mate_name])
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

        subscribeChannelMap(channel_id: channel.id!)

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
        unsubscribeChannelMap(channel_id: channel.id!)
        if let index = openedChannel.index(of: channel.id!) {
            openedChannel.remove(at: index)
        }
        if mapDataReceiver[channel.id!] != nil {
            mapDataReceiver[channel.id!]!.removeValue(forKey: key)
        }
    }

    func forgeLocation(_ vc: UIViewController, channel: Channel, location: CLLocationCoordinate2D) {
        var payload = [Key.CHANNEL:channel.id!, Key.LATITUDE: location.latitude, Key.LONGITUDE: location.longitude] as [String:Any]
        if channel.active != false {
            payload[Key.ACTIVE] = false
        }
        publish("client/\(clientId!)/channel/put", payload)
        _ = DialogSendSharingNotification(vc, channel.id!)
    }

    func setTS(_ ts: UInt64) {
        let ots = getTS()
        if ts > ots {
            UserDefaults.standard.set(NSNumber(value: ts), forKey: Key.TS)
        }
    }

    func getTS() -> UInt64 {
        return UInt64(truncating: UserDefaults.standard.object(forKey: Key.TS) as? NSNumber ?? 0)
    }

    func setTS(_ channel_id: String, _ ts: UInt64) {
        let ots = getTS(channel_id)
        if ts > ots {
            UserDefaults.standard.set(NSNumber(value: ts), forKey: "\(Key.TS)/\(channel_id)")
        }
    }

    func getTS(_ channel_id: String) -> UInt64 {
        return UInt64(truncating: UserDefaults.standard.object(forKey: "\(Key.TS)/\(channel_id)") as? NSNumber ?? 0)
    }

    func clearTS(_ channel_id: String) {
        UserDefaults.standard.removeObject(forKey: "\(Key.TS)/\(channel_id)")
    }

    var apiKeyCallback = [String:[ApiKeyCallback]]()

    func mqttSystemKeyHandler(_ data: [String:Any]) {
        guard let api = data[Key.API] as? String else {
            return
        }
        guard let key = data[Key.KEY] as? String else {
            return
        }
        UserDefaults.standard.set(key, forKey: Key.API_PREFIX+api)
        DispatchQueue.main.async {
            if self.apiKeyCallback[api] != nil {
                while self.apiKeyCallback[api]!.count > 0 {
                    let callback = self.apiKeyCallback[api]!.remove(at: 0)
                    callback.apiKey(key)
                }
            }
        }
    }

    func getKey(forApi: String, callback: ApiKeyCallback) {
        if let key = UserDefaults.standard.string(forKey: Key.API_PREFIX+forApi) {
            callback.apiKey(key)
            return
        }
        if apiKeyCallback[forApi] == nil {
            apiKeyCallback[forApi] = [ApiKeyCallback]()
        }
        apiKeyCallback[forApi]!.append(callback)
        publish("system/key/get", [Key.API:forApi])
    }

    func invalidateKey(forApi: String) {
        UserDefaults.standard.removeObject(forKey: Key.API_PREFIX+forApi)
    }

    var isForeground = false
    func _checkLocationService() {
        var pending = false
        var activeCount = 0

        for channel in channelList {
            if channel.active == nil {
                pending = true
                break
            } else if channel.active == true {
                activeCount += 1
            }
        }

        if !pending && isActiveDevice == true && activeCount > 0 {
            isForeground = true
            startLocationService()
        }
        if isActiveDevice != true || (!pending && activeCount == 0) {
            isForeground = false
            stopLocationService()
        }
    }

    func subscribeChannelMap(channel_id: String) {
        subscribe("channel/\(channel_id)/map/+/get")
    }

    func unsubscribeChannelMap(channel_id: String) {
        unsubscribe("channel/\(channel_id)/map/+/get")
    }

    func publish(_ topic: String, _ message: [String: Any]) {
        DispatchQueue.main.async {
            do {
                let json = try JSONSerialization.data(withJSONObject: message, options: [])
                print("publish \(topic) \(String(data: json, encoding: .utf8)!)")
                if let client = self.mqttSession?.mqttClient {
                    client.publish(json, topic: topic, qos: 1, retain: false)
                }
            } catch {
                print("error in publish()")
            }
        }
    }

    func subscribe(_ topic: String) {
        if subscribedTopics.contains(topic) {
            return
        }
        subscribedTopics.append(topic)
        if let client = mqttSession?.mqttClient {
            client.subscribe(topic, qos: 1)
        }
    }

    func unsubscribe(_ topicFilter: String) {
        if let client = mqttSession?.mqttClient {
            client.unsubscribe(topicFilter)
        }
        if let index = subscribedTopics.index(of: topicFilter) {
            subscribedTopics.remove(at: index)
        }
    }

    func getPowerSaving() -> Bool {
        return UserDefaults.standard.bool(forKey: Key.POWER_SAVING)
    }

    func setPowerSaving(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Key.POWER_SAVING)
    }

    func enterBackground() {
        inBackground = true
        if locationServiceRunning {
            Log.insert("enterBackground")
        }
    }

    func enterForeground() {
        inBackground = false
        if locationServiceRunning {
            Log.insert("enterForeground")
            if getPowerSaving() {
                lm.stopUpdatingLocation()
                lm.distanceFilter = kCLDistanceFilterNone
                lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationServiceIdled = false
                movingState = MovingState.generic
                lm.startUpdatingLocation()
            }
        }
    }

    var inBackground = true
    var locationServiceIdled = false
    var locationServiceRunning = false
    let lm = CLLocationManager()
    var rawLastLocation: CLLocation?
    var lastLocation: CLLocation?
    var idledLocation: CLLocation?
    func startLocationService() {
        if locationServiceRunning {
            return
        }
        locationServiceRunning = true
        lm.pausesLocationUpdatesAutomatically = false
        lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        lm.startUpdatingLocation()
    }

    func stopLocationService() {
        lm.stopUpdatingLocation()
        locationServiceRunning = false
        if locationServiceRunning {
            Log.insert("stopLocationService")
        }
    }

    enum MovingState {
        case generic
        case stop
        case walkingOrBiking
        case inVehicle
    }
    var movingState = MovingState.generic
    var stopLocation: CLLocation?
    var stopTime = 0.0
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if rawLastLocation != nil && location.timestamp.timeIntervalSince(rawLastLocation!.timestamp) <= 0 {
                return
            }
            rawLastLocation = location
            let coarse = locationServiceIdled
            if inBackground && getPowerSaving() {
                let time = NSDate().timeIntervalSince1970
                if locationServiceIdled {
                    if idledLocation!.distance(from: location) >= Config.LOCATION_CHANGE_IDLE_DISTANCE_THRESHOLD {
                        locationServiceIdled = false
                        lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                        stopTime = time
                        Log.insert("location change resume")
                    }
                } else {
                    if location.speed < 0.6 { //  2.16 kph
                        if movingState != .stop {
                            movingState = .stop
                            stopLocation = location
                            stopTime = time
                            lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                            Log.insert("movingState: stop \(location.speed)")
                        } else {
                            if !locationServiceIdled {
                                if time - stopTime >= Config.LOCATION_CHANGE_IDLE_TIME_THRESHOLD && stopLocation!.distance(from: location) < Config.LOCATION_CHANGE_IDLE_DISTANCE_THRESHOLD {
                                    idledLocation = location
                                    lm.desiredAccuracy = kCLLocationAccuracyThreeKilometers
                                    locationServiceIdled = true
                                    Log.insert("location change idled")
                                }
                            }
                        }
                        lm.allowDeferredLocationUpdates(untilTraveled: CLLocationDistance(15), timeout: TimeInterval(Config.LOCATION_UPDATE_MIN_INTERVAL))
                    } else if location.speed < 10 { // 36 kph
                        if movingState != .walkingOrBiking {
                            movingState = .walkingOrBiking
                            locationServiceIdled = false
                            lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                            Log.insert("movingState: walkingOrBiking \(location.speed)")
                        }
                        lm.allowDeferredLocationUpdates(untilTraveled: CLLocationDistance(location.speed * 5), timeout: TimeInterval(Config.LOCATION_UPDATE_MIN_INTERVAL))
                    } else {
                        if movingState != .inVehicle {
                            movingState = .inVehicle
                            locationServiceIdled = false
                            lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                            Log.insert("movingState: inVehicle")
                        }
                        lm.allowDeferredLocationUpdates(untilTraveled: CLLocationDistance(location.speed * 15), timeout: TimeInterval(Config.LOCATION_UPDATE_MIN_INTERVAL))
                    }
                }
            } else {
                if movingState != .generic {
                    movingState = .generic
                    locationServiceIdled = false
                    lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    Log.insert("movingState: generic")
                }
                lm.allowDeferredLocationUpdates(untilTraveled: CLLocationDistance(Config.GENERIC_LOCATION_UPDATE_MIN_DISTANCE), timeout: TimeInterval(Config.GENERIC_LOCATION_UPDATE_MIN_TIME))
            }

            if !coarse {
                processLocation(location: location)
            }
        }
    }

    func processLocation(location: CLLocation) {
        var time_criteria = true
        var distance_criteria = true
        if lastLocation != nil && location.timestamp.timeIntervalSince(lastLocation!.timestamp) < Config.LOCATION_UPDATE_MIN_INTERVAL {
            time_criteria  = false
        }
        if lastLocation != nil && lastLocation!.distance(from: location) < Config.LOCATION_UPDATE_MIN_DISTANCE {
            distance_criteria = false
        }
        if !time_criteria && !distance_criteria {
            return
        }

        lastLocation = location

        var data = [
            Key.LATITUDE: location.coordinate.latitude,
            Key.LONGITUDE: location.coordinate.longitude,
            Key.ACCURACY: location.horizontalAccuracy,
            Key.ALTITUDE: location.altitude,
//            Key.TIME: location.timestamp.timeIntervalSince1970,
            Key.PROVIDER: "iOS"
        ] as [String: Any]
        if location.course >= 0 {
            data[Key.BEARING] = location.course
        }
        if location.speed >= 0 {
            data[Key.SPEED] = location.speed
        }
        publish("client/\(clientId!)/location/put", data)
    }
}
