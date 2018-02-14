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

class Enchantment: RowConvertible, Persistable {
    static let TABLE_NAME = "enchantment"

    enum Columns {
        static let id = Column("_id")
        static let channel_id = Column("channel_id")
        static let name = Column("name")
        static let latitude = Column("latitude")
        static let longitude = Column("longitude")
        static let radius = Column("radius")
        static let is_public = Column("public")
        static let enabled = Column("enabled")
    }

    var id: String?
    var channel_id: String?
    var name: String?
    var latitude: Double?
    var longitude: Double?
    var radius: Int?
    var isPublic: Bool?
    var enabled: Bool?
    var deleted = false

    static func migrate(_ db: Database, _ db_version: Int) throws {
        var version = db_version

        if version < 1 {
            var sql: String
            sql = """
            CREATE TABLE \(TABLE_NAME) (
                \(Columns.id.name) TEXT PRIMARY KEY,
                \(Columns.channel_id.name) TEXT,
                \(Columns.name.name) TEXT,
                \(Columns.latitude.name) DOUBLE PRECISION,
                \(Columns.longitude.name) DOUBLE PRECISION,
                \(Columns.radius.name) INTEGER,
                \(Columns.is_public.name) BOOLEAN,
                \(Columns.enabled.name) BOOLEAN
            )
            """
            try db.execute(sql)

            sql = "CREATE INDEX enchantment_index ON \(TABLE_NAME) (\(Columns.channel_id.name))"
            try db.execute(sql)

            version = 1
        }
    }

    static let databaseTableName = TABLE_NAME

    init(){
        // noop
    }

    required init(row: Row) {
        id = row[Columns.id]
        channel_id = row[Columns.channel_id]
        name = row[Columns.name]
        latitude = row[Columns.latitude]
        longitude = row[Columns.longitude]
        radius = row[Columns.radius]
        isPublic = row[Columns.is_public]
        enabled = row[Columns.enabled]
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.channel_id] = channel_id
        container[Columns.name] = name
        container[Columns.latitude] = latitude
        container[Columns.longitude] = longitude
        container[Columns.radius] = radius
        container[Columns.is_public] = isPublic
        container[Columns.enabled] = enabled
    }

    static func getAll() -> [Enchantment] {
        var ret = [Enchantment]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try CoreService.bind().dbConn!.inDatabase { db in
                let enchantments = try Enchantment.fetchAll(db, "SELECT * FROM \(TABLE_NAME) ORDER BY \(Columns.name.name) ASC")

                for e in enchantments {
                    ret.append(e)
                }
            }
        } catch {
            print("Error checking out enchantments \(error)")
        }
        return ret
    }
}
