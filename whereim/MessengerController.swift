//
//  MessengerController.swift
//  whereim
//
//  Created by Buganini Q on 07/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MessengerController: JSQMessagesViewController, Callback {
    var messageList: BundledMessages?
    var service: CoreService?
    var channel: Channel?
    var cbkey: Int?

    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())

    let formatter = DateFormatter()

    override func viewDidLoad() {
        self.edgesForExtendedLayout = []

        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

        self.inputToolbar?.contentView?.leftBarButtonItem = nil

        // This is how you remove Avatars from the messagesView
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero

        // This is a beta feature that mostly works but to make things more stable I have diabled it.
        collectionView?.collectionViewLayout.springinessEnabled = false

        automaticallyScrollsToMostRecentMessage = true

        let parent = self.tabBarController as! ChannelController
        channel = parent.channel

        service = CoreService.bind()

        senderId = channel!.mate_id!
        senderDisplayName = service!.getChannelMate(channel!.id!, senderId).getDisplayName()

        messageList = service!.getMessages(channel!.id!)

        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()

        super.viewDidLoad()
    }

    func onCallback() {
        messageList = service!.getMessages(channel!.id!)
        self.finishReceivingMessage(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cbkey = service!.addMessageListener(channel!, cbkey, self)

        // topLayoutGuide.length is 0 at the moment ...
        let inset = collectionView.contentInset
        let newinset = UIEdgeInsetsMake(60, 0, inset.bottom, 0)
        collectionView.contentInset = newinset
        collectionView.scrollIndicatorInsets = newinset
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let sv = service {
            sv.removeMessageListener(channel!, cbkey)
        }

        super.viewWillDisappear(animated)
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        service!.sendMessage(channel!.id!, text)
        self.finishSendingMessage(animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageList!.message.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messageList!.message[indexPath.item].getJSQMessage()
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messageList!.message[indexPath.item].mate_id == channel!.mate_id! ? outgoingBubble : incomingBubble
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if messageList!.message[indexPath.item].mate_id == nil {
            return NSAttributedString(string: "")
        } else {
            let mate = service!.getChannelMate(channel!.id!, messageList!.message[indexPath.item].mate_id!)
            return NSAttributedString(string: mate.getDisplayName())
        }
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return messageList!.message[indexPath.item].mate_id == channel!.mate_id! ? 0 : kJSQMessagesCollectionViewCellLabelHeightDefault
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return NSAttributedString(string: formatter.string(from: messageList!.message[indexPath.item].getJSQMessage().date!))
    }
}
