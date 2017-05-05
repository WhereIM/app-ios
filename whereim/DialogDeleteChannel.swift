//
//  DialogDeleteChannel.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class DialogDeleteChannel {
    init(_ viewController: UIViewController, _ channel: Channel) {
        let alert = UIAlertController(title: "leave_channel".localized, message: channel.getName(), preferredStyle: .alert)

        let action_leave = UIAlertAction(title: "leave".localized, style: .destructive) { (alert: UIAlertAction!) -> Void in
            let service = CoreService.bind()
            service.deleteChannel(channel)
        }

        alert.addAction(action_leave)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion:nil)
    }
}
