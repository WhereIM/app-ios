//
//  DialogSendSharingNotification.swift
//  whereim
//
//  Created by Buganini Q on 13/02/2018.
//  Copyright © 2018 Where.IM. All rights reserved.
//

import UIKit

class DialogSendSharingNotification {
    init(_ viewController: UIViewController, _ channel_id: String) {
        let alert = UIAlertController(title: nil, message: "begin_sharing".localized, preferredStyle: .alert)
        let action_ok = UIAlertAction(title: "ok".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let service = CoreService.bind()
            service.sendNotification(channel_id, "begin_sharing")
        }

        alert.addAction(action_ok)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion:nil)
    }
}
