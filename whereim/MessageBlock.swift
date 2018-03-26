//
//  MessageBlock.swift
//  whereim
//
//  Created by Buganini Q on 26/03/2018.
//  Copyright © 2018 Where.IM. All rights reserved.
//

class MessageBlock {
    let count: Int
    let loadMoreBefore: Int64
    let loadMoreAfter: Int64
    let firstId: Int64
    let lastId: Int64
    let loadMoreChannelMessage: Bool
    let loadMoreUserMessage: Bool

    init(_ count: Int, _ before: Int64, _ after: Int64, _ first: Int64, _ last: Int64, _ loadByChannel: Bool, _ loadByUser: Bool) {
        self.count = count
        self.loadMoreBefore = before
        self.loadMoreAfter = after
        self.firstId = first
        self.lastId = last
        self.loadMoreChannelMessage = loadByChannel
        self.loadMoreUserMessage = loadByUser
    }

    static func get(_ channel_id: String) -> MessageBlock {
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
        var lastId: Int64 = -1

        do {
            try CoreService.bind().dbConn!.inDatabase { db in
                let cursor = try Message.fetchCursor(
                    db,
                    """
                    SELECT
                    \(Message.Columns.id.name),
                    \(Message.Columns.sn.name),
                    \(Message.Columns.is_public.name),
                    \(Message.Columns.channel.name),
                    \(Message.Columns.mate.name),
                    \(Message.Columns.type.name),
                    \(Message.Columns.message.name),
                    \(Message.Columns.time.name),
                    \(Message.Columns.type.name)
                    FROM \(Message.TABLE_NAME)
                    WHERE
                    \(Message.Columns.channel.name)=?
                    OR
                    \(Message.Columns.channel.name) IS NULL
                    ORDER BY \(Message.Columns.id.name) DESC
                    """,
                    arguments: [channel_id]
                )

                while let m = try cursor.next() {
                    if lastId < 0 {
                        lastId = m.id!
                    }
                    firstId = m.id!
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
            }
        } catch {
            print("Error reading message \(error)")
        }
        return MessageBlock(count, loadMoreBefore, loadMoreAfter, firstId, lastId, loadMoreChannelMessage, loadMoreUserMessage)
    }
}
