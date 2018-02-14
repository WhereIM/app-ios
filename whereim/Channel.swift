//
//  File.swift
//  whereim
//
//  Created by Buganini Q on 18/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import GRDB

class Channel: RowConvertible, Persistable {
    static let TABLE_NAME = "channel"

    enum Columns {
        static let id = Column("_id")
        static let channel_name = Column("channel_name")
        static let user_channel_name = Column("user_channel_name")
        static let mate = Column("mate")
        static let active = Column("active")
        static let enabled = Column("enabled")
        static let enable_radius = Column("enable_radius")
        static let radius = Column("radius")
        static let unread = Column("unread")
        static let is_public = Column("public")
    }

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
            sql = """
            CREATE TABLE \(TABLE_NAME) (
                \(Columns.id.name) TEXT PRIMARY KEY,
                \(Columns.channel_name.name) TEXT,
                \(Columns.user_channel_name.name) TEXT,
                \(Columns.mate.name) TEXT,
                \(Columns.active.name) BOOLEAN,
                \(Columns.enabled.name) BOOLEAN,
                \(Columns.enable_radius.name) BOOLEAN,
                \(Columns.radius.name) INTEGER
            )
            """
            try db.execute(sql)

            version = 1
        }
        if version < 3 {
            var sql: String
            sql = "ALTER TABLE \(TABLE_NAME) ADD COLUMN \(Columns.unread.name) BOOLEAN NOT NULL DEFAULT 0"
            try db.execute(sql)

            version = 3
        }
        if version < 4 {
            var sql: String
            sql = "ALTER TABLE \(TABLE_NAME) ADD COLUMN \(Columns.is_public.name) BOOLEAN NOT NULL DEFAULT 0"
            try db.execute(sql)

            version = 4
        }
    }

    static let databaseTableName = TABLE_NAME

    init() {
        // noop
    }

    required init(row: Row) {
        id = row[Columns.id]
        channel_name = row[Columns.channel_name]
        user_channel_name = row[Columns.user_channel_name]
        mate_id = row[Columns.mate]
        enabled = row[Columns.enabled]
        active = row[Columns.active]
        enable_radius = row[Columns.enable_radius]
        radius = row[Columns.radius]
        unread = row[Columns.unread]
        is_public = row[Columns.is_public]
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.channel_name] = channel_name
        container[Columns.user_channel_name] = user_channel_name
        container[Columns.mate] = mate_id
        container[Columns.active] = active ?? false
        container[Columns.enabled] = enabled ?? true
        container[Columns.enable_radius] = enable_radius ?? true
        container[Columns.radius] = radius
        container[Columns.is_public] = is_public
        container[Columns.unread] = unread
    }

    static func getAll() -> [Channel] {
        var ret = [Channel]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try CoreService.bind().dbConn!.inDatabase { db in
                let channels = try Channel.fetchAll(db, "SELECT * FROM \(TABLE_NAME) ORDER BY COALESCE(\(Columns.user_channel_name.name),\(Columns.channel_name.name))")

                for c in channels {
                    ret.append(c)
                }
            }
        } catch {
            print("Error checking out channels \(error)")
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
