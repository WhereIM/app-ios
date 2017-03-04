//
//  Dialog.swift
//  whereim
//
//  Created by Buganini Q on 03/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class Dialog {
    static func join_channel(_ rootViewController: UIViewController, _ channel_id: String) {
        let alert = UIAlertController(title: "Join Channel".localized, message: nil, preferredStyle: .alert)
        var display_name: UITextField?
        alert.addTextField(configurationHandler: { (field) in
            display_name = field
            field.placeholder = "display_name".localized
            field.text = UserDefaults.standard.string(forKey: Key.NAME)
        })
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default){ _ in
            if display_name?.text == nil {
                return
            }
            let service = CoreService.bind()
            let mate_name = (display_name?.text)!
            service.joinChannel(channel_id: channel_id, channel_alias: "", mate_name: mate_name)
        })
        rootViewController.present(alert, animated: true, completion: nil)
    }
}
