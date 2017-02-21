//
//  Mate.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

class Mate {
    var id: String?
    var channel_id: String?
    var mate_name: String?
    var user_mate_name: String?

    var latitude: Double?
    var longitude: Double?
    var accuracy: Double?
    var altitude: Double?
    var bearing: Double?
    var speed: Double?
    var time: UInt64?

    func getDisplayName() -> String? {
        return user_mate_name ?? mate_name
    }
}
