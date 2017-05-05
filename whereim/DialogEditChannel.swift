//
//  DialogEditChannel.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView
import UIKit

class DialogEditChannel {
    let alert = AlertController(title: "edit_channel".localized, message: nil, preferredStyle: .alert)
    let layout = UICompactStackView()
    let channel_name = UICompactStackView()
    let channel_name_label = UILabel()
    let channel_name_edit = UITextField()
    let channel_alias = UICompactStackView()
    let channel_alias_label = UILabel()
    let channel_alias_edit = UITextField()

    init(_ viewController: UIViewController, _ channel: Channel) {
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            let service = CoreService.bind()
            let _channel_name = (self.channel_name_edit.text)!
            let _channel_alias = (self.channel_alias_edit.text)!
            service.editChannel(channel, _channel_name, _channel_alias)
        }
        alert.add(action)

        func check() {
            action.isEnabled = !channel_name_edit.text!.isEmpty
        }

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .leading
        layout.distribution = .fill
        layout.spacing = 5

        channel_name.translatesAutoresizingMaskIntoConstraints = false
        channel_name.axis = .horizontal
        channel_name.alignment = .center
        channel_name.distribution = .fill
        channel_name.spacing = 5

        channel_name_label.translatesAutoresizingMaskIntoConstraints = false
        channel_name_label.adjustsFontSizeToFitWidth = false
        channel_name_label.text = "channel_name".localized
        channel_name.addArrangedSubview(channel_name_label)

        channel_name_edit.text = channel.channel_name
        channel_name_edit.translatesAutoresizingMaskIntoConstraints = false
        channel_name_edit.backgroundColor = .white
        channel_name_edit.layer.borderColor = UIColor.gray.cgColor
        channel_name_edit.layer.borderWidth = 1
        channel_name_edit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        channel_name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: channel_name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }

        channel_name.addArrangedSubview(channel_name_edit)

        layout.addArrangedSubview(channel_name)

        channel_alias.translatesAutoresizingMaskIntoConstraints = false
        channel_alias.axis = .horizontal
        channel_alias.alignment = .center
        channel_alias.distribution = .fill
        channel_alias.spacing = 5

        channel_alias_label.translatesAutoresizingMaskIntoConstraints = false
        channel_alias_label.adjustsFontSizeToFitWidth = false
        channel_alias_label.text = "channel_alias".localized
        channel_alias.addArrangedSubview(channel_alias_label)

        channel_alias_edit.text = channel.user_channel_name
        channel_alias_edit.translatesAutoresizingMaskIntoConstraints = false
        channel_alias_edit.backgroundColor = .white
        channel_alias_edit.layer.borderColor = UIColor.gray.cgColor
        channel_alias_edit.layer.borderWidth = 1
        channel_alias_edit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        channel_alias_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: channel_alias_edit, queue: OperationQueue.main) { (notification) in
            check()
        }

        channel_alias.addArrangedSubview(channel_alias_edit)

        layout.addArrangedSubview(channel_alias)

        layout.requestLayout()

        check()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}
