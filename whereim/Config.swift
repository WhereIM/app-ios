//
//  Config.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//


class Config {
    static let GOOGLE_MAP_KEY = "AIzaSyAtP4_TFI7E_88lUQQTo9NBqJvF9KcC8HA"

    static let FACEBOOK_SLUG = "facebook"

    static let CAPTCHA_URL = "https://where.im/captcha.html"
    static let CAPTCHA_PREFIX = "whereim://"

    static let AWS_IOT_MQTT_ENDPOINT = "a3ftvwpcurxils.iot.ap-northeast-1.amazonaws.com"
    static let AWS_IOT_MQTT_PORT = 8883
    static let AWS_API_GATEWAY_REGISTER_CLIENT = "https://gznzura26h.execute-api.ap-northeast-1.amazonaws.com/production"

    static let ENCHANTMENT_RADIUS = [15, 30, 50, 75, 100, 150, 200, 250, 300, 400, 500, 1000, 1500, 2000, 3000]
    static let DEFAULT_ENCHANTMENT_RADIUS_INDEX = 2
}
