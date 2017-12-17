//
//  Log.swift
//  whereim
//
//  Created by Buganini Q on 12/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import GRDB
import UIKit

class Log: RowConvertible, Persistable {
    static let TABLE_NAME = "syslog"

    enum Columns {
        static let id = Column("_id")
        static let time = Column("time")
        static let message = Column("message")
    }

    static func migrate(_ db: Database, _ db_version: Int) throws {
        var version = db_version

        if version < 1 {
            var sql: String
            sql = """
            CREATE TABLE \(TABLE_NAME) (
                \(Columns.id.name) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(Columns.time.name) DATETIME,
                \(Columns.message.name) TEXT
            )
            """
            try db.execute(sql)

            version = 1
        }
    }

    static let databaseTableName = TABLE_NAME

    required init(row: Row) {
        id = row[Columns.id]
        time = row[Columns.time]
        message = row[Columns.message]
    }

    init(_ log: String) {
        time = Date()
        message = log
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.time] = time
        container[Columns.message] = message
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
            print("Error saving logs \(error)")
        }

        print("log: \(message)")

        let notification = UILocalNotification()
        notification.fireDate = Date(timeIntervalSinceNow: 0)
        notification.alertBody = "log: \(message)"
        notification.timeZone = NSTimeZone.default

        UIApplication.shared.scheduleLocalNotification(notification)
    }

    static func getAll() -> [Log] {
        var ret = [Log]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try appDelegate.dbConn!.inDatabase { db in
                let logs = try Log.fetchAll(db, "SELECT * FROM \(TABLE_NAME) ORDER BY \(Columns.time.name) ASC")

                for l in logs {
                    ret.append(l)
                }
            }
        } catch {
            print("Error checking out logs \(error)")
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
