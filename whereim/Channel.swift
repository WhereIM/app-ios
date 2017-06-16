//
//  File.swift
//  whereim
//
//  Created by Buganini Q on 18/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import GRDB

class Channel: Record {
    static let TABLE_NAME = "channel"

    static let COL_ID = "_id"
    static let COL_CHANNEL_NAME = "channel_name"
    static let COL_USER_CHANNEL_NAME = "user_channel_name"
    static let COL_MATE = "mate"
    static let COL_ACTIVE = "active"
    static let COL_ENABLE = "enabled"
    static let COL_ENABLE_RADIUS = "enable_radius"
    static let COL_RADIUS = "radius"
    static let COL_UNREAD = "unread"
    static let COL_PUBLIC = "public"

    var id: String?
    var channel_name: String?
    var user_channel_name: String?
    var mate_id: String?
    var enabled: Bool?
    var active: Bool?
    var enable_radius: Bool?
    var radius: Int?
    var deleted = false
    var unread = false
    var is_public = false

    static func migrate(_ db: Database, _ db_version: Int) throws {
        var version = db_version

        if version < 1 {
            var sql: String
            sql = "CREATE TABLE " + TABLE_NAME + " (" +
                COL_ID + " TEXT PRIMARY KEY, " +
                COL_CHANNEL_NAME + " TEXT, " +
                COL_USER_CHANNEL_NAME + " TEXT, " +
                COL_MATE + " TEXT, " +
                COL_ACTIVE + " BOOLEAN, " +
                COL_ENABLE + " BOOLEAN, " +
                COL_ENABLE_RADIUS + " BOOLEAN, " +
                COL_RADIUS + " INTEGER" +
            ")";
            try db.execute(sql)

            version = 1
        }
        if version < 3 {
            var sql: String
            sql = "ALTER TABLE " + TABLE_NAME + " ADD COLUMN " + COL_UNREAD + " BOOLEAN NOT NULL DEFAULT 0"
            try db.execute(sql)

            version = 3
        }
        if version < 4 {
            var sql: String
            sql = "ALTER TABLE " + TABLE_NAME + " ADD COLUMN " + COL_PUBLIC + " BOOLEAN NOT NULL DEFAULT 0"
            try db.execute(sql)

            version = 4
        }
    }

    override class var databaseTableName: String {
        return TABLE_NAME
    }

    required init(row: Row) {
        id = row.value(named: Channel.COL_ID)
        channel_name = row.value(named: Channel.COL_CHANNEL_NAME)
        user_channel_name = row.value(named: Channel.COL_USER_CHANNEL_NAME)
        mate_id = row.value(named: Channel.COL_MATE)
        enabled = row.value(named: Channel.COL_ENABLE)
        active = row.value(named: Channel.COL_ACTIVE)
        enable_radius = row.value(named: Channel.COL_ENABLE_RADIUS)
        radius = row.value(named: Channel.COL_RADIUS)
        unread = row.value(named: Channel.COL_UNREAD)
        is_public = row.value(named: Channel.COL_PUBLIC)
        super.init(row: row)
    }

    override init() {
        super.init()
    }

    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return [
            Channel.COL_ID: id,
            Channel.COL_CHANNEL_NAME: channel_name,
            Channel.COL_USER_CHANNEL_NAME: user_channel_name,
            Channel.COL_MATE: mate_id,
            Channel.COL_ACTIVE: active,
            Channel.COL_ENABLE: enabled,
            Channel.COL_ENABLE_RADIUS: enable_radius,
            Channel.COL_RADIUS: radius,
            Channel.COL_PUBLIC: is_public,
            Channel.COL_UNREAD: unread
        ]
    }

    static func getAll() -> [Channel] {
        var ret = [Channel]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try appDelegate.dbConn!.inDatabase { db in
                let channels = try Channel.fetchAll(db, "SELECT * FROM "+TABLE_NAME+" ORDER BY COALESCE("+COL_USER_CHANNEL_NAME+","+COL_CHANNEL_NAME+")")

                for c in channels {
                    ret.append(c)
                }
            }
        } catch {
            print("Error checking out channels")
        }
        return ret
    }

    func getName() -> String {
        if user_channel_name != nil && !user_channel_name!.isEmpty {
            return user_channel_name!
        }
        if channel_name != nil && !channel_name!.isEmpty {
            return channel_name!
        }
        return ""
    }

    func getLink() -> String {
        return String(format: Config.WHERE_IM_URL, "channel/\(id!)")
    }
}
