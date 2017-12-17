//
//  DialogCreateEnchantment.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView

class DialogCreateEnchantment {
    let alert = AlertController(title: "create_enchantment".localized, message: nil, preferredStyle: .alert)
    let layout = UIStackView()
    let name_label = UILabel()
    let name_edit = UITextField()
    let ispublic = UIStackView()
    let ispublic_label = UILabel()
    let ispublic_switch = UISwitch()

    init(_ mapController: MapController, _ title: String?) {
        alert.addAction(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            mapController.editingType = .enchantment
            mapController.editingEnchantment.id = nil
            mapController.editingEnchantment.name = self.name_edit.text
            mapController.editingEnchantment.latitude = mapController.editingCoordinate.latitude
            mapController.editingEnchantment.longitude = mapController.editingCoordinate.longitude
            mapController.editingEnchantment.radius = Config.DEFAULT_ENCHANTMENT_RADIUS
            mapController.editingEnchantment.isPublic = self.ispublic_switch.isOn
            mapController.refreshEditing()
        }
        alert.addAction(action)

        func check() {
            action.isEnabled = !name_edit.text!.isEmpty
        }

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .fill
        layout.distribution = .fill
        layout.spacing = 5

        name_label.translatesAutoresizingMaskIntoConstraints = false
        name_label.adjustsFontSizeToFitWidth = false
        name_label.text = "name".localized
        layout.addArrangedSubview(name_label)

        name_edit.translatesAutoresizingMaskIntoConstraints = false
        name_edit.text = title
        name_edit.backgroundColor = .white
        name_edit.layer.borderColor = UIColor.gray.cgColor
        name_edit.layer.borderWidth = 1
        name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }
        check()
        layout.addArrangedSubview(name_edit)

        ispublic.translatesAutoresizingMaskIntoConstraints = false
        ispublic.axis = .horizontal
        ispublic.alignment = .center
        ispublic.distribution = .fill
        ispublic.spacing = 5

        ispublic_label.translatesAutoresizingMaskIntoConstraints = false
        ispublic_label.adjustsFontSizeToFitWidth = false
        ispublic_label.text = "is_public".localized
        ispublic.addArrangedSubview(ispublic_label)

        ispublic_switch.setOn(true, animated: false)
        ispublic.addArrangedSubview(ispublic_switch)

        layout.addArrangedSubview(ispublic)

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.widthAnchor.constraint(equalTo: alert.contentView.widthAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        mapController.present(alert, animated: true, completion: nil)
    }
}
