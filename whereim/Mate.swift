//
//  Mate.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import GRDB

class Mate: Record {
    static let TABLE_NAME = "mate"

    static let COL_ID = "_id"
    static let COL_CHANNEL_ID = "channel_id"
    static let COL_MATE_NAME = "mate_name"
    static let COL_USER_MATE_NAME = "user_mate_name"

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
    var deleted = false

    static func migrate(_ db: Database, _ db_version: Int) throws {
        var version = db_version

        if version < 1 {
            var sql: String
            sql = "CREATE TABLE " + TABLE_NAME + " (" +
                COL_ID + " TEXT PRIMARY KEY, " +
                COL_CHANNEL_ID + " TEXT, " +
                COL_MATE_NAME + " TEXT, " +
                COL_USER_MATE_NAME + " TEXT)"
            try db.execute(sql)

            sql = "CREATE INDEX mate_index ON "+TABLE_NAME+" ("+COL_CHANNEL_ID+")"
            try db.execute(sql)

            version = 1
        }
    }

    override class var databaseTableName: String {
        return TABLE_NAME
    }

    required init(row: Row) {
        id = row.value(named: Mate.COL_ID)
        channel_id = row.value(named: Mate.COL_CHANNEL_ID)
        mate_name = row.value(named: Mate.COL_MATE_NAME)
        user_mate_name = row.value(named: Mate.COL_USER_MATE_NAME)
        super.init(row: row)
    }

    override init() {
        super.init()
    }

    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return [
            Mate.COL_ID: id,
            Mate.COL_CHANNEL_ID: channel_id,
            Mate.COL_MATE_NAME: mate_name,
            Mate.COL_USER_MATE_NAME: user_mate_name
        ]
    }

    static func getAll() -> [Mate] {
        var ret = [Mate]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try appDelegate.dbConn!.inDatabase { db in
                let mates = try Mate.fetchAll(db, "SELECT * FROM "+TABLE_NAME)

                for m in mates {
                    ret.append(m)
                }
            }
        } catch {
            print("Error checking out mates")
        }
        return ret
    }

    func getDisplayName() -> String {
        return user_mate_name ?? mate_name ?? ""
    }
}
