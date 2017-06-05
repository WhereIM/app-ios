//
//  Config.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import Foundation

enum MapProvider: String {
    case GOOGLE = "google"
    case MAPBOX = "mapbox"
}

class Config {
    static let LOGGING = false

    static let DB_VERSION = 3

    static let KEY_FILE = "whereim.key"
    static let CRT_FILE = "whereim.crt"

    static let GOOGLE_MAP_KEY = "AIzaSyAtP4_TFI7E_88lUQQTo9NBqJvF9KcC8HA"
    static let MAPBOX_KEY = "pk.eyJ1Ijoid2hlcmVpbSIsImEiOiJjaXltbmtvbHUwMDM4MzNwZnNsZHVtbHE4In0.n36bMG_LdA9yOu8-fQS2vw"

    static let FACEBOOK_SLUG = "facebook"

    static let CAPTCHA_URL = "https://dev.where.im/captcha.html"
    static let CAPTCHA_PREFIX = "whereim://"

    static let WHERE_IM_URL = "https://dev.where.im/%@"

    static let AWS_IOT_MQTT_ENDPOINT = "a3ftvwpcurxils.iot.ap-northeast-1.amazonaws.com"
    static let AWS_IOT_MQTT_PORT = 8883
    static let AWS_API_GATEWAY_REGISTER_CLIENT = "https://gznzura26h.execute-api.ap-northeast-1.amazonaws.com/production"

    static let SELF_RADIUS = [75, 100, 150, 200, 250, 300, 400, 500, 1000, 1500, 2000, 3000]
    static let ENCHANTMENT_RADIUS = [50, 75, 100, 150, 200, 250, 300, 400, 500, 1000, 1500, 2000, 3000]
    static let DEFAULT_ENCHANTMENT_RADIUS_INDEX = 1

    static let LOCATION_CHANGE_IDLE_DISTANCE_THRESHOLD = 50.0 //m
    static let LOCATION_CHANGE_IDLE_TIME_THRESHOLD = 300.0 // s
    static let LOCATION_UPDATE_MIN_INTERVAL = 15.0 // s
    static let LOCATION_UPDATE_MIN_DISTANCE = 15.0 // m
    static let GENERIC_LOCATION_UPDATE_MIN_TIME = 10.0 // s
    static let GENERIC_LOCATION_UPDATE_MIN_DISTANCE = 5.0 // m

    static func getMapProvider() -> MapProvider {
        return MapProvider.init(rawValue: UserDefaults.standard.string(forKey: Key.PROVIDER) ?? MapProvider.GOOGLE.rawValue) ?? MapProvider.GOOGLE
    }

    static func setMapProvider(_ provider: MapProvider) {
        UserDefaults.standard.set(provider.rawValue, forKey: Key.PROVIDER)
    }
}
