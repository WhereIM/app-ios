//
//  PendingMessage.swift
//  whereim
//
//  Created by Buganini Q on 26/03/2018.
//  Copyright © 2018 Where.IM. All rights reserved.
//

import GRDB

class PendingMessage: RowConvertible, Persistable {
    let service = CoreService.bind()

    static let TABLE_NAME = "pending_message";

    enum Columns {
        static let id = Column("_id")
        static let hash = Column("hash")
        static let channel = Column("channel")
        static let type = Column("type")
        static let payload = Column("payload")
    }

    var id: Int64?
    var hash: String?
    var channel_id: String?
    var type: String?
    var payload = [String:Any]()

    static func migrate(_ db: Database, _ db_version: Int) throws {
        var version = db_version

        if version < 5 {
            var sql: String
            sql = """
            CREATE TABLE \(TABLE_NAME) (
            \(Columns.id.name) INTEGER PRIMARY KEY,
            \(Columns.hash.name) TEXT,
            \(Columns.channel.name) TEXT,
            \(Columns.type.name) TEXT,
            \(Columns.payload.name) TEXT
            )
            """
            try db.execute(sql)

            sql = "CREATE INDEX pending_message_index ON \(TABLE_NAME) (\(Columns.hash.name))"
            try db.execute(sql)

            version = 5
        }
    }

    static let databaseTableName = TABLE_NAME

    init(){
        // noop
    }

    required init(row: Row) {
        id = row[Columns.id]
        hash = row[Columns.hash]
        channel_id = row[Columns.channel]
        type = row[Columns.type]
        do {
            payload = try JSONSerialization.jsonObject(with: row[Columns.payload], options: []) as! [String: Any]
        } catch {
            print("error decoding pending message payload")
        }
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        if hash == nil {
            let uid = UUID().uuidString
            let time = NSDate().timeIntervalSince1970 * 1000
            hash = "\(uid)\(time)"
        }
        container[Columns.hash] = hash
        container[Columns.channel] = channel_id
        container[Columns.type] = type
        do {
            let json = try JSONSerialization.data(withJSONObject: payload, options: [])
            container[Columns.payload] = String(data: json, encoding: .utf8)!
        } catch {
            print("error in publish()")
        }
    }

    func getFile() -> String? {
        return payload["file"] as? String
    }

    static func pop(_ db: Database) -> PendingMessage? {
        do {
            let cursor = try PendingMessage.fetchCursor(db, "SELECT * FROM \(TABLE_NAME) ORDER BY \(Columns.id.name) ASC LIMIT 1")
            if let m = try cursor.next() {
                return m
            }
        } catch {
            print("Error getting pending message \(error)")
        }
        return nil
    }

    static func delete(_ db: Database, _ hash: String) {
        do {
            let cursor = try PendingMessage.fetchCursor(db, "SELECT * FROM \(TABLE_NAME) WHERE \(Columns.hash.name)=?", arguments: [hash])
            if let m = try cursor.next() {
                do {
                    let prefix = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    if let f = m.getFile() {
                        let path = prefix.appendingPathComponent(f)
                        try FileManager.default.removeItem(at: path)
                    }
                } catch {
                    print("Error deleting pending image file")
                }
            }

            try db.execute("DELETE FROM \(TABLE_NAME) WHERE \(Columns.hash.name)=?", arguments: [hash])
        } catch {
            print("Error deleting pending message \(error)")
        }
    }

    static func getMessage(_ db: Database, _ channel_id: String) -> [PendingMessage] {
        var ret = [PendingMessage]()
        do {
            let cursor = try PendingMessage.fetchCursor(db, "SELECT * FROM \(TABLE_NAME) WHERE \(Columns.channel.name)=? AND \(Columns.type.name)!='ctrl' ORDER BY \(Columns.id.name) DESC", arguments: [channel_id])
            while let m = try cursor.next() {
                ret.append(m)
            }
        } catch {
            print("Error reading pending messages \(error)")
        }
        return ret
    }
}
