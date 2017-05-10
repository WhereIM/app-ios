//
//  DialogNewChannel.swift
//  whereim
//
//  Created by Buganini Q on 09/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class DialogNewChannel {
    init(_ viewController: UIViewController, _ view: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action_qrcode = UIAlertAction(title: "scan_qr_code".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "scan_qr_code".localized, style: .plain, target: nil, action: nil)
            viewController.performSegue(withIdentifier: "scanner", sender: nil)
        }

        let action_create = UIAlertAction(title: "create_channel".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            _ = DialogCreateChannel(viewController)
        }

        alert.addAction(action_qrcode)
        alert.addAction(action_create)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = view
        viewController.present(alert, animated: true, completion:nil)
    }
}
