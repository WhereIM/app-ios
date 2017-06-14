//
//  DialogEditMarker.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView
import UIKit

class DialogEditMarker {
    let alert = AlertController(title: nil, message: nil, preferredStyle: .alert)
    let layout = UIStackView()
    let name_label = UILabel()
    let name_edit = UITextField()
    let ispublic = UIStackView()
    let ispublic_label = UILabel()
    let ispublic_switch = UISwitch()
    let icon = UIStackView()
    let icon_label = UILabel()
    let icon_picker = UIPickerView()
    let pickerDelegate = PickerDelegate()

    init(_ viewController: ChannelController, _ marker: Marker) {
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            viewController.edit(marker: marker, name: self.name_edit.text!, attr: [Key.COLOR: self.pickerDelegate.getItem(self.icon_picker.selectedRow(inComponent: 0))], shared: marker.isPublic! || self.ispublic_switch.isOn)
        }

        alert.add(action)

        func check(){
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

        name_edit.text = marker.name
        name_edit.translatesAutoresizingMaskIntoConstraints = false
        name_edit.backgroundColor = .white
        name_edit.layer.borderColor = UIColor.gray.cgColor
        name_edit.layer.borderWidth = 1
        name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }

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

        ispublic_switch.setOn(false, animated: false)
        ispublic.addArrangedSubview(ispublic_switch)

        layout.addArrangedSubview(ispublic)

        if marker.isPublic == true {
            ispublic.isHidden = true
        }

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.axis = .horizontal
        icon.alignment = .center
        icon.distribution = .fill
        icon.spacing = 5

        icon_label.translatesAutoresizingMaskIntoConstraints = false
        icon_label.adjustsFontSizeToFitWidth = false
        icon_label.text = "icon".localized
        icon.addArrangedSubview(icon_label)

        icon_picker.translatesAutoresizingMaskIntoConstraints = false
        icon_picker.dataSource = pickerDelegate
        icon_picker.delegate = pickerDelegate
        icon_picker.showsSelectionIndicator = true
        icon_picker.heightAnchor.constraint(equalToConstant: 162).isActive = true
        icon_picker.selectRow(pickerDelegate.icon_list.index(of: marker.getColor()) ?? 0, inComponent: 0, animated: false)
        icon.addArrangedSubview(icon_picker)

        layout.addArrangedSubview(icon)

        check()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.widthAnchor.constraint(equalTo: alert.contentView.widthAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}
