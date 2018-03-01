//
//  Message.swift
//  whereim
//
//  Created by Buganini Q on 06/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import GRDB

class BundledMessages {
    let message: [Message]
    let loadMoreBefore: Int64
    let loadMoreAfter: Int64
    let firstId: Int64
    let lastId: Int64
    let loadMoreChannelMessage: Bool
    let loadMoreUserMessage: Bool
    var rowMap: [Int64:Int]

    init (
        message: [Message],
        loadMoreBefore: Int64,
        loadMoreAfter: Int64,
        firstId: Int64,
        lastId: Int64,
        loadMoreChannelMessage: Bool,
        loadMoreUserMessage: Bool) {

        self.message = message
        self.loadMoreBefore = loadMoreBefore
        self.loadMoreAfter = loadMoreAfter
        self.firstId = firstId
        self.lastId = lastId
        self.loadMoreChannelMessage = loadMoreChannelMessage
        self.loadMoreUserMessage = loadMoreUserMessage
        self.rowMap = [Int64:Int]()

        for i in 0..<message.count {
            rowMap[message[i].id!] = i
        }

        print("count", message.count)
        print("loadMoreBefore", loadMoreBefore)
        print("loadMoreAfter", loadMoreAfter)
        print("firstId", firstId)
        print("lastId", lastId)
        print("loadMoreChannelMessage", loadMoreChannelMessage)
        print("loadMoreUserMessage", loadMoreUserMessage)
    }
}

class Message: RowConvertible, Persistable {
    let service = CoreService.bind()

    static let TABLE_NAME = "message";

    enum Columns {
        static let id = Column("_id")
        static let sn = Column("sn")
        static let channel = Column("channel")
        static let is_public = Column("public")
        static let mate = Column("mate")
        static let type = Column("type")
        static let message = Column("message")
        static let time = Column("time")
    }

    var id: Int64?
    var sn: Int64?
    var channel_id: String?
    var mate_id: String?
    var type: String?
    var message: String?
    var time: Int64?
    var notify: Int?
    var isPublic: Bool?

    static func migrate(_ db: Database, _ db_version: Int) throws {
        var version = db_version
        
        if version < 1 {
            var sql: String
            sql = """
            CREATE TABLE \(TABLE_NAME) (
                \(Columns.id.name) INTEGER PRIMARY KEY,
                \(Columns.sn.name) INTEGER,
                \(Columns.channel.name) TEXT NULL,
                \(Columns.is_public.name) BOOLEAN,
                \(Columns.mate.name) TEXT,
                \(Columns.type.name) TEXT,
                \(Columns.message.name) TEXT,
                \(Columns.time.name) INTEGER
            )
            """
            try db.execute(sql)

            sql = "CREATE INDEX message_index ON \(TABLE_NAME) (\(Columns.channel.name))"
            try db.execute(sql)

            version = 1
        }
    }

    func getSender() -> String {
        var sender: String?
        if channel_id == nil {
            sender = "system"
        } else {
            if mate_id == nil {
                sender = ""
            } else {
                sender = service.getChannelMate(channel_id!, mate_id!).getDisplayName()
            }
        }
        return sender!
    }

    func getText() -> String {
        if type == "text" {
            return message!
        } else {
            do {
                let attr: [String: Any]?
                do {
                    attr = try JSONSerialization.jsonObject(with: message!.data(using: .utf8)!, options: []) as? [String: Any]
                } catch {
                    attr = nil
                }
                switch type! {
                case "enchantment_create":
                    let s = String(format: "message_enchantment_create".localized, (attr?[Key.NAME] as? String) ?? "")
                    return s
                case "enchantment_emerge":
                    let s = String(format: "message_enchantment_emerge".localized, (attr?[Key.NAME] as? String) ?? "")
                    return s
                case "enchantment_in":
                    let s = String(format: "message_enchantment_in".localized, (attr?[Key.NAME] as? String) ?? "")
                    return s
                case "enchantment_out":
                    let s = String(format: "message_enchantment_out".localized, (attr?[Key.NAME] as? String) ?? "")
                    return s
                case "marker_create":
                    let s = String(format: "message_marker_create".localized, (attr?[Key.NAME] as? String) ?? "")
                    return s
                case "radius_report":
                    let s = String(format: "message_radius_report".localized, attr!["in"] as? String ?? "", attr!["out"] as? String ?? "", attr![Key.RADIUS] as? String ?? "")
                    return s
                default:
                    return "message_not_implemented".localized
                }
            } catch {
                print("Error decoding message attr")
                return ""
            }
        }
    }

    static let databaseTableName = TABLE_NAME

    required init(row: Row) {
        id = row[Columns.id]
        sn = row[Columns.sn]
        channel_id = row[Columns.channel]
        mate_id = row[Columns.mate]
        type = row[Columns.type]
        message = row[Columns.message]
        time = row[Columns.time]
        isPublic = row[Columns.is_public]
    }

    init(_ data: [String: Any]) {
        id = data[Key.ID] as! Int64?
        sn = data[Key.SN] as! Int64?
        channel_id = data[Key.CHANNEL] as? String
        mate_id = data[Key.MATE] as? String
        type = data["type"] as? String
        message = data["message"] as? String
        isPublic = data[Key.PUBLIC] as? Bool
        time = data["time"] as! Int64?
        notify = data["notify"] as? Int
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.sn] = sn
        container[Columns.channel] = channel_id
        container[Columns.mate] = mate_id
        container[Columns.type] = type
        container[Columns.message] = message
        container[Columns.time] = time
        container[Columns.is_public] = isPublic!
    }

    static func getMessages(_ channel_id: String) -> BundledMessages {
        var count = 0
        var loadMoreBefore: Int64 = 0
        var loadMoreAfter: Int64 = 0
        var loadMoreChannelMessage = false
        var loadMoreUserMessage = false
        var hasChannelData = false
        var hasUserData = false
        var channelDataSn: Int64 = 0
        var channelDataId: Int64 = 0
        var userDataSn: Int64 = 0
        var userDataId: Int64 = 0
        var firstId: Int64 = 0
        var lastId: Int64 = 0

        var messages = [Message]()
        do {
            try CoreService.bind().dbConn!.inDatabase { db in
                let cursor = try Message.fetchCursor(
                    db,
                    """
                    SELECT
                        \(Columns.id.name),
                        \(Columns.sn.name),
                        \(Columns.is_public.name),
                        \(Columns.channel.name),
                        \(Columns.mate.name),
                        \(Columns.type.name),
                        \(Columns.message.name),
                        \(Columns.time.name),
                        \(Columns.type.name)
                    FROM \(TABLE_NAME)
                    WHERE
                        \(Columns.channel.name)=?
                        OR
                        \(Columns.channel.name) IS NULL
                    ORDER BY \(Columns.id.name) DESC
                    """,
                    arguments: [channel_id]
                )

                while let m = try cursor.next() {
                    messages.append(m)
                    count += 1;
                    if m.channel_id == nil {
                        continue;
                    }
                    if m.isPublic == true {
                        if !hasChannelData {
                            hasChannelData = true
                            channelDataSn = m.sn!
                        } else {
                            if m.sn == channelDataSn - 1 {
                                channelDataSn = m.sn!
                                channelDataId = m.id!
                            } else {
                                loadMoreBefore = channelDataId
                                loadMoreAfter = m.id!
                                loadMoreChannelMessage = true
                                break
                            }
                        }
                    } else if m.isPublic == false {
                        if !hasUserData {
                            hasUserData = true
                            userDataSn = m.sn!
                        } else {
                            if m.sn == userDataSn - 1 {
                                userDataSn = m.sn!
                                userDataId = m.id!
                            } else {
                                loadMoreBefore = userDataId
                                loadMoreAfter = m.id!
                                loadMoreUserMessage = true
                                break
                            }
                        }
                    }
                }
                firstId = messages.last?.id! ?? 0
                lastId = messages.first?.id! ?? 0
            }
        } catch {
            print("Error reading message \(error)")
        }
        return BundledMessages(message: messages, loadMoreBefore: loadMoreBefore, loadMoreAfter: loadMoreAfter, firstId: firstId, lastId: lastId, loadMoreChannelMessage: loadMoreChannelMessage, loadMoreUserMessage: loadMoreUserMessage)
    }
}
