//
//  DialogJoinChannel.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView
import UIKit

class DialogJoinChannel {
    let alert = AlertController(title: "join_channel".localized, message: nil, preferredStyle: .alert)
    let layout = UIStackView()
    let display_name_label = UILabel()
    let display_name_edit = UITextField()

    init(_ viewController: UIViewController, _ channel_id: String) {
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            let service = CoreService.bind()
            let mate_name = (self.display_name_edit.text)!
            service.joinChannel(channel_id: channel_id, channel_alias: "", mate_name: mate_name)
        }
        alert.add(action)

        func check(){
            action.isEnabled = !display_name_edit.text!.isEmpty
        }

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .fill
        layout.distribution = .fill
        layout.spacing = 5

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
