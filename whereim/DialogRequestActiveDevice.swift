//
//  DialogRequestActiveDevice.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class DialogRequestActiveDevice {
    init(_ viewController: UIViewController) {
        let alert = UIAlertController(title: "active_client".localized, message: "active_client_message".localized, preferredStyle: .alert)
        let action_ok = UIAlertAction(title: "ok".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let service = CoreService.bind()
            service.setActive()
        }

        alert.addAction(action_ok)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion:nil)
    }
}
