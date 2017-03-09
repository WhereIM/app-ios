//
//  Message.swift
//  whereim
//
//  Created by Buganini Q on 06/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import GRDB
import JSQMessagesViewController

class BundledMessages {
    let message: [Message]
    let loadMoreBefore: Int64
    let loadMoreAfter: Int64
    let firstId: Int64
    let lastId: Int64
    let loadMoreChannelMessage: Bool
    let loadMoreUserMessage: Bool

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

        print("count", message.count)
        print("loadMoreBefore", loadMoreBefore)
        print("loadMoreAfter", loadMoreAfter)
        print("firstId", firstId)
        print("lastId", lastId)
        print("loadMoreChannelMessage", loadMoreChannelMessage)
        print("loadMoreUserMessage", loadMoreUserMessage)
    }
}

class Message: Record {
    let service = CoreService.bind()

    var jsqMessage: JSQMessage?
    func getJSQMessage() -> JSQMessage {
        if jsqMessage == nil {
            var displayName: String?
            if channel_id == nil {
                displayName = "system"
            } else {
                displayName = service.getChannelMate(channel_id!, mate_id!).getDisplayName()
            }
            let date = Date(timeIntervalSince1970: TimeInterval(time!))
            jsqMessage = JSQMessage(senderId: mate_id!, senderDisplayName: displayName!, date: date, text: "\(type!): \(message!)")
        }
        return jsqMessage!
    }

    static let TABLE_NAME = "message";

    static let COL_ID = "_id"
    static let COL_SN = "sn"
    static let COL_CHANNEL = "channel"
    static let COL_PUBLIC = "public"
    static let COL_MATE = "mate"
    static let COL_TYPE = "type"
    static let COL_MESSAGE = "message"
    static let COL_TIME = "time"

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
            sql = "CREATE TABLE " + TABLE_NAME + " (" +
                COL_ID + " INTEGER PRIMARY KEY, " +
                COL_SN + " INTEGER, " +
                COL_CHANNEL + " TEXT NULL, " +
                COL_PUBLIC + " BOOLEAN, " +
                COL_MATE + " TEXT, " +
                COL_TYPE + " TEXT, " +
                COL_MESSAGE + " TEXT, " +
                COL_TIME + " INTEGER)"
            try db.execute(sql)

            sql = "CREATE INDEX message_index ON "+TABLE_NAME+" ("+COL_CHANNEL+")"
            try db.execute(sql)

            version = 1
        }
    }

    override class var databaseTableName: String {
        return TABLE_NAME
    }

    required init(row: Row) {
        id = row.value(named: Message.COL_ID)
        sn = row.value(named: Message.COL_SN)
        channel_id = row.value(named: Message.COL_CHANNEL)
        mate_id = row.value(named: Message.COL_MATE)
        type = row.value(named: Message.COL_TYPE)
        message = row.value(named: Message.COL_MESSAGE)
        time = row.value(named: Message.COL_TIME)
        isPublic = row.value(named: Message.COL_PUBLIC)
        super.init(row: row)
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
        super.init()
    }

    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return [
            Message.COL_ID: id,
            Message.COL_SN: sn,
            Message.COL_CHANNEL: channel_id,
            Message.COL_MATE: mate_id,
            Message.COL_TYPE: type,
            Message.COL_MESSAGE: message,
            Message.COL_TIME: time,
            Message.COL_PUBLIC: isPublic!
        ]
    }

    static func getMessages(_ channel_id: String) -> BundledMessages {
        var message: [Message]?
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

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try appDelegate.dbConn!.inDatabase { db in
                message = try Message.fetchAll(db, "SELECT "+COL_ID+","+COL_SN+","+COL_PUBLIC+","+COL_CHANNEL+","+COL_MATE+","+COL_TYPE+","+COL_MESSAGE+","+COL_TIME+" FROM "+TABLE_NAME+" WHERE "+COL_CHANNEL+"=? OR "+COL_CHANNEL+" IS NULL ORDER BY "+COL_TIME+" ASC,"+COL_ID+" ASC", arguments: [channel_id])

                for m in message!.reversed() {
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
                firstId = message?.first?.id! ?? 0
                lastId = message?.last?.id! ?? 0
            }
        } catch {
            print("Error reading message \(error)")
        }
        var avail = message
        if count > 0 {
            avail = Array(message![0...count-1])
        }
        return BundledMessages(message: avail!, loadMoreBefore: loadMoreBefore, loadMoreAfter: loadMoreAfter, firstId: firstId, lastId: lastId, loadMoreChannelMessage: loadMoreChannelMessage, loadMoreUserMessage: loadMoreUserMessage)
    }
}
