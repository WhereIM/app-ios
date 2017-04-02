//
//  Enchantment.swift
//  whereim
//
//  Created by Buganini Q on 22/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import GRDB

class EnchantmentList {
    var public_list = [Enchantment]()
    var private_list = [Enchantment]()
}

class Enchantment: Record {
    static let TABLE_NAME = "enchantment"

    static let COL_ID = "_id"
    static let COL_CHANNEL_ID = "channel_id"
    static let COL_NAME = "name"
    static let COL_LATITUDE = "latitude"
    static let COL_LONGITUDE = "longitude"
    static let COL_RADIUS = "radius"
    static let COL_PUBLIC = "public"
    static let COL_ENABLE = "enable"

    var id: String?
    var channel_id: String?
    var name: String?
    var latitude: Double?
    var longitude: Double?
    var radius: Double?
    var isPublic: Bool?
    var enable: Bool?
    var deleted = false

    static func migrate(_ db: Database, _ db_version: Int) throws {
        var version = db_version

        if version < 1 {
            var sql: String
            sql = "CREATE TABLE " + TABLE_NAME + " (" +
                COL_ID + " TEXT PRIMARY KEY, " +
                COL_CHANNEL_ID + " TEXT, " +
                COL_NAME + " TEXT, " +
                COL_LATITUDE + " DOUBLE PRECISION, " +
                COL_LONGITUDE + " DOUBLE PRECISION, " +
                COL_RADIUS + " DOUBLE PRECISION, " +
                COL_PUBLIC + " BOOLEAN, " +
                COL_ENABLE + " BOOLEAN)";
            try db.execute(sql)

            sql = "CREATE INDEX enchantment_index ON "+TABLE_NAME+" ("+COL_CHANNEL_ID+")"
            try db.execute(sql)

            version = 1
        }
    }

    override class var databaseTableName: String {
        return TABLE_NAME
    }

    required init(row: Row) {
        id = row.value(named: Enchantment.COL_ID)
        channel_id = row.value(named: Enchantment.COL_CHANNEL_ID)
        name = row.value(named: Enchantment.COL_NAME)
        latitude = row.value(named: Enchantment.COL_LATITUDE)
        longitude = row.value(named: Enchantment.COL_LONGITUDE)
        radius = row.value(named: Enchantment.COL_RADIUS)
        isPublic = row.value(named: Enchantment.COL_PUBLIC)
        enable = row.value(named: Enchantment.COL_ENABLE)
        super.init(row: row)
    }

    override init() {
        super.init()
    }

    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return [
            Enchantment.COL_ID: id,
            Enchantment.COL_CHANNEL_ID: channel_id,
            Enchantment.COL_NAME: name,
            Enchantment.COL_LATITUDE: latitude,
            Enchantment.COL_LONGITUDE: longitude,
            Enchantment.COL_RADIUS: radius,
            Enchantment.COL_PUBLIC: isPublic,
            Enchantment.COL_ENABLE: enable
        ]
    }

    static func getAll() -> [Enchantment] {
        var ret = [Enchantment]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try appDelegate.dbConn!.inDatabase { db in
                let enchantments = try Enchantment.fetchAll(db, "SELECT * FROM "+TABLE_NAME+" ORDER BY "+COL_NAME+" ASC")

                for e in enchantments {
                    ret.append(e)
                }
            }
        } catch {
            print("Error checking out enchantments")
        }
        return ret
    }
}
