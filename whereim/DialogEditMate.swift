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
    let layout = UICompactStackView()
    let mate_name_label = UILabel()
    let user_mate_name = UICompactStackView()
    let user_mate_name_label = UILabel()
    let user_mate_name_edit = UITextField()

    init(_ viewController: UIViewController, _ mate: Mate) {
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            let service = CoreService.bind()
            let user_mate_name = (self.user_mate_name_edit.text)!
            service.editMate(mate, user_mate_name)
        }
        alert.add(action)

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .leading
        layout.distribution = .fill
        layout.spacing = 5

        mate_name_label.translatesAutoresizingMaskIntoConstraints = false
        mate_name_label.adjustsFontSizeToFitWidth = false
        mate_name_label.text = mate.mate_name
        layout.addArrangedSubview(mate_name_label)

        user_mate_name.translatesAutoresizingMaskIntoConstraints = false
        user_mate_name.axis = .horizontal
        user_mate_name.alignment = .center
        user_mate_name.distribution = .fill
        user_mate_name.spacing = 5

        user_mate_name_label.translatesAutoresizingMaskIntoConstraints = false
        user_mate_name_label.adjustsFontSizeToFitWidth = false
        user_mate_name_label.text = "name".localized
        user_mate_name.addArrangedSubview(user_mate_name_label)

        user_mate_name_edit.text = mate.user_mate_name
        user_mate_name_edit.translatesAutoresizingMaskIntoConstraints = false
        user_mate_name_edit.backgroundColor = .white
        user_mate_name_edit.layer.borderColor = UIColor.gray.cgColor
        user_mate_name_edit.layer.borderWidth = 1
        user_mate_name_edit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        user_mate_name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true

        user_mate_name.addArrangedSubview(user_mate_name_edit)

        layout.addArrangedSubview(user_mate_name)

        layout.requestLayout()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}
