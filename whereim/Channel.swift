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
    static let COL_ENABLE = "enable"

    var id: String?
    var channel_name: String?
    var user_channel_name: String?
    var mate_id: String?
    var enable: Bool?

    static func migrate(_ db: Database, _ db_version: Int) throws {
        var version = db_version

        if version < 1 {
            var sql: String
            sql = "CREATE TABLE " + TABLE_NAME + " (" +
                COL_ID + " TEXT PRIMARY KEY, " +
                COL_CHANNEL_NAME + " TEXT, " +
                COL_USER_CHANNEL_NAME + " TEXT, " +
                COL_MATE + " TEXT, " +
                COL_ENABLE + " INTEGER)"
            try db.execute(sql)

            version = 1
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
        enable = row.value(named: Channel.COL_ENABLE)
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
            Channel.COL_ENABLE: enable
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
}
