//
//  DialogEditSelf.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView
import UIKit

class DialogEditSelf {
    let alert = AlertController(title: nil, message: nil, preferredStyle: .alert)
    let layout = UIStackView()
    let mate_name_label = UILabel()
    let mate_name_edit = UITextField()

    init(_ viewController: UIViewController, _ mate: Mate) {
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            let service = CoreService.bind()
            let name = (self.mate_name_edit.text)!
            service.editSelf(mate, name)
        }
        alert.add(action)

        func check(){
            action.isEnabled = !mate_name_edit.text!.isEmpty
        }

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .fill
        layout.distribution = .fill
        layout.spacing = 5

        mate_name_label.translatesAutoresizingMaskIntoConstraints = false
        mate_name_label.adjustsFontSizeToFitWidth = false
        mate_name_label.text = "name".localized
        layout.addArrangedSubview(mate_name_label)

        mate_name_edit.text = mate.mate_name
        mate_name_edit.translatesAutoresizingMaskIntoConstraints = false
        mate_name_edit.backgroundColor = .white
        mate_name_edit.layer.borderColor = UIColor.gray.cgColor
        mate_name_edit.layer.borderWidth = 1
        mate_name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: mate_name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }

        layout.addArrangedSubview(mate_name_edit)

        check()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.widthAnchor.constraint(equalTo: alert.contentView.widthAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}
