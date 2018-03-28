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
    let pendingMessage: [PendingMessage]

    init (
        message: [Message],
        loadMoreBefore: Int64,
        loadMoreAfter: Int64,
        firstId: Int64,
        lastId: Int64,
        loadMoreChannelMessage: Bool,
        loadMoreUserMessage: Bool,
        pendingMessage: [PendingMessage]) {

        self.message = message
        self.loadMoreBefore = loadMoreBefore
        self.loadMoreAfter = loadMoreAfter
        self.firstId = firstId
        self.lastId = lastId
        self.loadMoreChannelMessage = loadMoreChannelMessage
        self.loadMoreUserMessage = loadMoreUserMessage
        self.pendingMessage = pendingMessage

        print("count", message.count)
        print("loadMoreBefore", loadMoreBefore)
        print("loadMoreAfter", loadMoreAfter)
        print("firstId", firstId)
        print("lastId", lastId)
        print("loadMoreChannelMessage", loadMoreChannelMessage)
        print("loadMoreUserMessage", loadMoreUserMessage)
    }
}

class Image {
    var key: String
    var width: Float
    var height: Float
    var ext: String

    init(_ key: String, _ width: Int, _ height: Int, _ ext: String){
        self.key = key
        self.width = Float(width)
        self.height = Float(height)
        self.ext = ext
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
        static let deleted = Column("deleted")
        static let hidden = Column("hidden")
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
    var deleted = false
    var hidden = false

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
        if version < 6 {
            var sql: String

            sql = "ALTER TABLE \(TABLE_NAME) ADD COLUMN \(Columns.deleted.name) BOOLEAN NOT NULL DEFAULT 0"
            try db.execute(sql)

            sql = "ALTER TABLE \(TABLE_NAME) ADD COLUMN \(Columns.hidden.name) BOOLEAN NOT NULL DEFAULT 0"
            try db.execute(sql)

            version = 6
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

    func getImage() -> Image? {
        do {
            guard let attr = try JSONSerialization.jsonObject(with: message!.data(using: .utf8)!, options: []) as? [String: Any] else {
                return nil
            }
            if type != "image" {
                return nil
            }
            guard let key = attr[Key.KEY] as? String else {
                return nil
            }
            guard let w = attr[Key.WIDTH] as? Int else {
                return nil
            }
            guard let h = attr[Key.HEIGHT] as? Int else {
                return nil
            }
            guard let ext = attr[Key.EXTENSION] as? String else {
                return nil
            }
            return Image(key, w, h, ext)
        } catch {
            return nil
        }
    }

    func getText() -> NSMutableAttributedString {
        if deleted {
            let textAttrs = [
                NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 17),
                NSAttributedStringKey.foregroundColor: UIColor.gray
                ] as [NSAttributedStringKey:Any]
            let s = NSMutableAttributedString(string: "message_deleted".localized)
            s.setAttributes(textAttrs, range: NSMakeRange(0, s.length))
            return s
        }
        if hidden {
            let textAttrs = [
                NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 17),
                NSAttributedStringKey.foregroundColor: UIColor.gray
                ] as [NSAttributedStringKey:Any]
            let s = NSMutableAttributedString(string: "message_hidden".localized)
            s.setAttributes(textAttrs, range: NSMakeRange(0, s.length))
            return s
        }
        return Message.getText(type!, message!)
    }

    static func getText(_ type: String, _ message: Any) -> NSMutableAttributedString {
        var textMessage: String?
        var jsonMessage: [String: Any]?
        var textAttrs = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)
        ] as [NSAttributedStringKey:Any]
        if let t = message as? String {
            textMessage = t
        }
        if let t = message as? [String:Any] {
            jsonMessage = t
        }
        if type == "text" {
            let r = NSMutableAttributedString(string: textMessage!)
            r.setAttributes(textAttrs, range: NSMakeRange(0, r.length))
            return r
        } else {
            do {
                var attr: [String: Any]?
                if let t = textMessage {
                    do {
                        attr = try JSONSerialization.jsonObject(with: t.data(using: .utf8)!, options: []) as? [String: Any]
                    } catch {
                        attr = nil
                    }
                }
                if let t = jsonMessage {
                    attr = t
                }
                switch type {
                case "rich":
                    let s = NSMutableAttributedString()
                    let text = NSMutableAttributedString(string: (attr?["text"] as? String) ?? "")
                    text.setAttributes(textAttrs, range: NSMakeRange(0, text.length))
                    if let lat = attr?[Key.LATITUDE] as? Double, let lng = attr?[Key.LONGITUDE] as? Double {
                        let attach = NSTextAttachment()
                        attach.image = UIImage(named: "icon_pin")
                        let ss = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attach))
                        ss.addAttribute(NSAttributedStringKey.link, value: "wim://pin/\(lat)/\(lng)", range: NSMakeRange(0, ss.length))
                        s.append(ss)
                        s.append(NSAttributedString(string: "\n"))
                    }
                    s.append(text)
                    return s
                case "enchantment_create":
                    let s = String(format: "message_enchantment_create".localized, (attr?[Key.NAME] as? String) ?? "")
                    let r = NSMutableAttributedString(string: s)
                    r.setAttributes(textAttrs, range: NSMakeRange(0, r.length))
                    return r
                case "enchantment_emerge":
                    let s = String(format: "message_enchantment_emerge".localized, (attr?[Key.NAME] as? String) ?? "")
                    let r = NSMutableAttributedString(string: s)
                    r.setAttributes(textAttrs, range: NSMakeRange(0, r.length))
                    return r
                case "enchantment_in":
                    let s = String(format: "message_enchantment_in".localized, (attr?[Key.NAME] as? String) ?? "")
                    let r = NSMutableAttributedString(string: s)
                    r.setAttributes(textAttrs, range: NSMakeRange(0, r.length))
                    return r
                case "enchantment_out":
                    let s = String(format: "message_enchantment_out".localized, (attr?[Key.NAME] as? String) ?? "")
                    let r = NSMutableAttributedString(string: s)
                    r.setAttributes(textAttrs, range: NSMakeRange(0, r.length))
                    return r
                case "marker_create":
                    let s = NSMutableAttributedString()
                    let text = NSMutableAttributedString(string: String(format: "message_marker_create".localized, (attr?[Key.NAME] as? String) ?? ""))
                    text.setAttributes(textAttrs, range: NSMakeRange(0, text.length))
                    if let sattr = attr?[Key.ATTR] as? [String: Any] {
                        if let color = sattr[Key.COLOR] as? String {
                            let attach = NSTextAttachment()
                            attach.image = Marker.getIcon(color)
                            let ss = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attach))
                            if let mid = attr?[Key.ID] as? String, let lat = attr?[Key.LATITUDE] as? Double, let lng = attr?[Key.LONGITUDE] as? Double {
                                ss.addAttribute(NSAttributedStringKey.link, value: "wim://marker/\(mid)/\(lat)/\(lng)", range: NSMakeRange(0, ss.length))
                            }
                            s.append(ss)
                        }
                    }
                    s.append(NSAttributedString(string: "\n"))
                    s.append(text)
                    return s
                case "radius_report":
                    let s = String(format: "message_radius_report".localized, attr!["in"] as? String ?? "", attr!["out"] as? String ?? "", attr![Key.RADIUS] as? String ?? "")
                    let r = NSMutableAttributedString(string: s)
                    r.setAttributes(textAttrs, range: NSMakeRange(0, r.length))
                    return r
                default:
                    textAttrs[NSAttributedStringKey.font] = UIFont.italicSystemFont(ofSize: 17)
                    textAttrs[NSAttributedStringKey.foregroundColor] = UIColor.gray
                    let s = NSMutableAttributedString(string: "message_not_implemented".localized)
                    s.setAttributes(textAttrs, range: NSMakeRange(0, s.length))
                    return s
                }
            } catch {
                print("Error decoding message attr")
                let s = NSMutableAttributedString(string: "")
                s.setAttributes(textAttrs, range: NSMakeRange(0, s.length))
                return s
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
        deleted = row[Columns.deleted]
        hidden = row[Columns.hidden]
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
        if let d = data[Key.DELETED] as? Bool {
            deleted = d
        }
        if let h = data[Key.HIDDEN] as? Bool {
            hidden = h
        }
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
        container[Columns.deleted] = deleted
        container[Columns.hidden] = hidden
    }

    static func setDeleted(_ channel_id: String, _ id: Int64) {
        do {
            try CoreService.bind().dbConn!.inDatabase { db in
                let sql = "UPDATE \(TABLE_NAME) SET \(Columns.deleted.name)=1, \(Columns.message.name)='' WHERE \(Columns.channel.name)=? AND \(Columns.id.name)=\(id)"
                try db.execute(sql, arguments: [channel_id])
            }
        } catch {
            print("Error in setDelete \(error)")
        }
    }

    static func setHidden(_ channel_id: String, _ id: Int64) {
        do {
            try CoreService.bind().dbConn!.inDatabase { db in
                let sql = "UPDATE \(TABLE_NAME) SET \(Columns.hidden.name)=1, \(Columns.message.name)='' WHERE \(Columns.channel.name)=? AND \(Columns.id.name)=\(id)"
                try db.execute(sql, arguments: [channel_id])
            }
        } catch {
            print("Error in setDelete \(error)")
        }
    }

    static func getMessages(_ channel_id: String) -> BundledMessages {
        let mb = MessageBlock.get(channel_id)

        var messages = [Message]()
        var pendingMessage = [PendingMessage]()
        do {
            try CoreService.bind().dbConn!.inDatabase { db in
                let cursor = try Message.fetchCursor(
                    db,
                    """
                    SELECT * FROM \(TABLE_NAME)
                    WHERE
                        \(Columns.id.name)>=\(mb.firstId)
                        AND
                        \(Columns.id.name)<=\(mb.lastId)
                        AND
                        \(Columns.type.name)!='ctrl'
                        AND (
                            \(Columns.channel.name)=?
                            OR
                            \(Columns.channel.name) IS NULL
                        )
                    ORDER BY \(Columns.id.name) DESC
                    """,
                    arguments: [channel_id]
                )

                while let m = try cursor.next() {
                    messages.append(m)
                }
                pendingMessage = PendingMessage.getMessage(db, channel_id)
            }
        } catch {
            print("Error reading message \(error)")
        }
        let firstId = messages.last?.id ?? -1
        let lastId = messages.first?.id ?? -1
        return BundledMessages(message: messages, loadMoreBefore: mb.loadMoreBefore, loadMoreAfter: mb.loadMoreAfter, firstId: firstId, lastId: lastId, loadMoreChannelMessage: mb.loadMoreChannelMessage, loadMoreUserMessage: mb.loadMoreUserMessage, pendingMessage: pendingMessage)
    }
}
