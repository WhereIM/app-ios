//
//  DialogCreateChannel.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView
import UIKit

class DialogCreateChannel {
    let alert = AlertController(title: "create_channel".localized, message: nil, preferredStyle: .alert)
    let layout = UIStackView()
    let channel_name_label = UILabel()
    let channel_name_edit = UITextField()
    let display_name_label = UILabel()
    let display_name_edit = UITextField()

    init(_ viewController: UIViewController) {
        alert.addAction(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            let service = CoreService.bind()
            let _channel_name = (self.channel_name_edit.text)!
            let _mate_name = (self.display_name_edit.text)!
            service.createChannel(channel_name: _channel_name, mate_name: _mate_name)
        }
        alert.addAction(action)

        func check() {
            action.isEnabled = !channel_name_edit.text!.isEmpty && !display_name_edit.text!.isEmpty
        }

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .fill
        layout.distribution = .fill
        layout.spacing = 5

        channel_name_label.translatesAutoresizingMaskIntoConstraints = false
        channel_name_label.adjustsFontSizeToFitWidth = false
        channel_name_label.text = "channel_name".localized
        layout.addArrangedSubview(channel_name_label)

        channel_name_edit.translatesAutoresizingMaskIntoConstraints = false
        channel_name_edit.backgroundColor = .white
        channel_name_edit.layer.borderColor = UIColor.gray.cgColor
        channel_name_edit.layer.borderWidth = 1
        channel_name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: channel_name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }

        layout.addArrangedSubview(channel_name_edit)

        display_name_label.translatesAutoresizingMaskIntoConstraints = false
        display_name_label.adjustsFontSizeToFitWidth = false
        display_name_label.text = "display_name".localized
        layout.addArrangedSubview(display_name_label)

        display_name_edit.text = UserDefaults.standard.string(forKey: Key.NAME)
        display_name_edit.translatesAutoresizingMaskIntoConstraints = false
        display_name_edit.backgroundColor = .white
        display_name_edit.layer.borderColor = UIColor.gray.cgColor
        display_name_edit.layer.borderWidth = 1
        display_name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: display_name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }

        layout.addArrangedSubview(display_name_edit)

        check()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.widthAnchor.constraint(equalTo: alert.contentView.widthAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}
