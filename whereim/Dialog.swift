//
//  Dialog.swift
//  whereim
//
//  Created by Buganini Q on 03/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class Dialog {
    static func join_channel(_ viewController: UIViewController, _ channel_id: String) {
        let alert = UIAlertController(title: "Join Channel".localized, message: nil, preferredStyle: .alert)
        var display_name: UITextField?

        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        let action = UIAlertAction(title: "ok".localized, style: .destructive){ _ in
            let service = CoreService.bind()
            let mate_name = (display_name?.text)!
            service.joinChannel(channel_id: channel_id, channel_alias: "", mate_name: mate_name)
        }
        alert.addAction(action)

        func check(){
            action.isEnabled = !display_name!.text!.isEmpty
        }

        alert.addTextField(configurationHandler: { (field) in
            display_name = field

            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            label.text = "display_name".localized
            field.leftView = label
            field.leftViewMode = .always

            field.text = UserDefaults.standard.string(forKey: Key.NAME)
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: field, queue: OperationQueue.main) { (notification) in
                check()
            }
        })
        check()
        viewController.present(alert, animated: true, completion: nil)
    }

    static func create_channel(_ viewController: UIViewController) {
        let alert = UIAlertController(title: "Create Channel".localized, message: nil, preferredStyle: .alert)
        var channel_name: UITextField?
        var display_name: UITextField?

        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        let action = UIAlertAction(title: "ok".localized, style: .destructive){ _ in
            let service = CoreService.bind()
            let _channel_name = (channel_name?.text)!
            let _mate_name = (display_name?.text)!
            service.createChannel(channel_name: _channel_name, mate_name: _mate_name)
        }
        alert.addAction(action)

        func check(){
            action.isEnabled = !channel_name!.text!.isEmpty && !display_name!.text!.isEmpty
        }

        alert.addTextField(configurationHandler: { (field) in
            channel_name = field

            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            label.text = "channel_name".localized
            field.leftView = label
            field.leftViewMode = .always

            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: field, queue: OperationQueue.main) { (notification) in
                check()
            }
        })
        alert.addTextField(configurationHandler: { (field) in
            display_name = field

            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            label.text = "display_name".localized
            field.leftView = label
            field.leftViewMode = .always

            field.text = UserDefaults.standard.string(forKey: Key.NAME)
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: field, queue: OperationQueue.main) { (notification) in
                check()
            }
        })
        check()
        viewController.present(alert, animated: true, completion: nil)
    }
}
