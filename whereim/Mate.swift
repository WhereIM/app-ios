//
//  Mate.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import GRDB

class Mate: RowConvertible, Persistable {
    static let TABLE_NAME = "mate"

    enum Columns {
        static let id = Column("_id")
        static let channel_id = Column("channel_id")
        static let mate_name = Column("mate_name")
        static let user_mate_name = Column("user_mate_name")
        static let deleted = Column("deleted")
    }

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
    var stale = false
    var deleted = false

    static func migrate(_ db: Database, _ db_version: Int) throws {
        var version = db_version

        if version < 1 {
            var sql: String
            sql = """
            CREATE TABLE \(TABLE_NAME) (
                \(Columns.id.name) TEXT PRIMARY KEY,
                \(Columns.channel_id.name) TEXT,
                \(Columns.mate_name.name) TEXT,
                \(Columns.user_mate_name.name) TEXT
            )
            """
            try db.execute(sql)

            sql = "CREATE INDEX mate_index ON \(TABLE_NAME) (\(Columns.channel_id.name))"
            try db.execute(sql)

            version = 1
        }
        if version < 2 {
            var sql: String
            sql = "ALTER TABLE \(TABLE_NAME) ADD COLUMN \(Columns.deleted.name) BOOLEAN NOT NULL DEFAULT 0"
            try db.execute(sql)

            version = 2
        }
    }

    static let databaseTableName = TABLE_NAME

    init() {
        // noop
    }

    required init(row: Row) {
        id = row[Columns.id]
        channel_id = row[Columns.channel_id]
        mate_name = row[Columns.mate_name]
        user_mate_name = row[Columns.user_mate_name]
        deleted = row[Columns.deleted]
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.channel_id] = channel_id
        container[Columns.mate_name] = mate_name
        container[Columns.user_mate_name] = user_mate_name
        container[Columns.deleted] = deleted
    }

    static func getAll() -> [Mate] {
        var ret = [Mate]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try CoreService.bind().dbConn!.inDatabase { db in
                let mates = try Mate.fetchAll(db, "SELECT * FROM \(TABLE_NAME)")

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
        if user_mate_name != nil && !user_mate_name!.isEmpty {
            return user_mate_name!
        }
        if mate_name != nil && !mate_name!.isEmpty {
            return mate_name!
        }
        return ""
    }
}
