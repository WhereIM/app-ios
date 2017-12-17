//
//  DialogEditMate.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView
import UIKit

class DialogEditMate {
    let alert = AlertController(title: "join_channel".localized, message: nil, preferredStyle: .alert)
    let layout = UIStackView()
    let mate_name_label = UILabel()
    let mate_name_edit = UITextField()
    let user_mate_name_label = UILabel()
    let user_mate_name_edit = UITextField()

    init(_ viewController: UIViewController, _ mate: Mate) {
        alert.addAction(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            let service = CoreService.bind()
            let user_mate_name = (self.user_mate_name_edit.text)!
            service.editMate(mate, user_mate_name)
        }
        alert.addAction(action)

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .fill
        layout.distribution = .fill
        layout.spacing = 5

        mate_name_label.translatesAutoresizingMaskIntoConstraints = false
        mate_name_label.adjustsFontSizeToFitWidth = false
        mate_name_label.text = "name".localized
        layout.addArrangedSubview(mate_name_label)

        mate_name_edit.translatesAutoresizingMaskIntoConstraints = false
        mate_name_edit.adjustsFontSizeToFitWidth = false
        mate_name_edit.text = mate.mate_name
        mate_name_edit.isEnabled = false
        layout.addArrangedSubview(mate_name_edit)

        user_mate_name_label.translatesAutoresizingMaskIntoConstraints = false
        user_mate_name_label.adjustsFontSizeToFitWidth = false
        user_mate_name_label.text = "display_name".localized
        layout.addArrangedSubview(user_mate_name_label)

        user_mate_name_edit.text = mate.user_mate_name
        user_mate_name_edit.translatesAutoresizingMaskIntoConstraints = false
        user_mate_name_edit.backgroundColor = .white
        user_mate_name_edit.layer.borderColor = UIColor.gray.cgColor
        user_mate_name_edit.layer.borderWidth = 1
        user_mate_name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true

        layout.addArrangedSubview(user_mate_name_edit)

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.widthAnchor.constraint(equalTo: alert.contentView.widthAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}
