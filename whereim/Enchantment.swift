//
//  Enchantment.swift
//  whereim
//
//  Created by Buganini Q on 22/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

class EnchantmentList {
    var public_list = [Enchantment]()
    var private_list = [Enchantment]()
}

class Enchantment {
    var id: String?
    var channel_id: String?
    var name: String?
    var latitude: Double?
    var longitude: Double?
    var radius: Double?
    var isPublic: Bool?
    var enable: Bool?
}
