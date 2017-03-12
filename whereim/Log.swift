//
//  Log.swift
//  whereim
//
//  Created by Buganini Q on 12/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import GRDB
import UIKit

class Log: Record {
    static let TABLE_NAME = "syslog"

    static let COL_ID = "_id"
    static let COL_TIME = "time"
    static let COL_MESSAGE = "message"

    static func migrate(_ db: Database, _ db_version: Int) throws {
        var version = db_version

        if version < 1 {
            var sql: String
            sql = "CREATE TABLE " + TABLE_NAME + " (" +
                COL_ID + " INTEGER PRIMARY KEY AUTOINCREMENT, " +
                COL_TIME + " DATETIME, " +
                COL_MESSAGE + " TEXT)"
            try db.execute(sql)

            version = 1
        }
    }

    override class var databaseTableName: String {
        return TABLE_NAME
    }

    required init(row: Row) {
        id = row.value(named: Log.COL_ID)
        time = row.value(named: Log.COL_TIME)
        message = row.value(named: Log.COL_MESSAGE)
        super.init(row: row)
    }

    init(_ log: String) {
        time = Date()
        message = log
        super.init()
    }

    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return [
            Log.COL_TIME: time,
            Log.COL_MESSAGE: message
        ]
    }

    var id: Int?
    let time: Date
    let message: String

    static func insert(_ message: String) {
        if !Config.LOGGING {
            return
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try appDelegate.dbConn!.inDatabase { db in
                try Log(message).save(db)
            }
        } catch {
            print("Error checking out logs")
        }
    }

    static func getAll() -> [Log] {
        var ret = [Log]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try appDelegate.dbConn!.inDatabase { db in
                let logs = try Log.fetchAll(db, "SELECT * FROM "+TABLE_NAME+" ORDER BY "+COL_TIME+" ASC")

                for l in logs {
                    ret.append(l)
                }
            }
        } catch {
            print("Error checking out logs")
        }
        return ret
    }

    static func clear() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try appDelegate.dbConn!.inDatabase { db in
                try db.execute("DELETE FROM "+TABLE_NAME)
            }
        } catch {
            print("Error deleting logs")
        }
    }
}
