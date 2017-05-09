//
//  DialogChannelInvite.swift
//  whereim
//
//  Created by Buganini Q on 09/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//


import UIKit

class DialogChannelInvite {
    init(_ viewController: UIViewController, _ view: UIView, _ channel: Channel) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action_qrcode = UIAlertAction(title: "generate_qr_code".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            _ = DialogChannelInviteQrCode(viewController, channel)
        }

        let action_link = UIAlertAction(title: "send_invite_link".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            if let url = NSURL(string: channel.getLink()) {
                let objectsToShare = [String(format: "invitation".localized, channel.channel_name!), url] as [Any]
                let vc = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                vc.popoverPresentationController?.sourceView = view
                viewController.present(vc, animated: true, completion: nil)
            }
        }

        alert.addAction(action_qrcode)
        alert.addAction(action_link)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = view
        viewController.present(alert, animated: true, completion:nil)
    }
}
