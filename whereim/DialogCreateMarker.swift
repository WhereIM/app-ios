//
//  DialogCreateMarker.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView
import UIKit

class DialogCreateMarker {
    class PickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        let icon_list = Marker.getIconList()

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return icon_list.count
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            var cell: UIImageView?
            if let v = view {
                cell = v as? UIImageView
            }
            if cell == nil {
                cell = UIImageView(frame: CGRect(x: 0, y: 0, width: 43, height: 43))
            }
            cell!.image = Marker.getIcon(icon_list[row])
            return cell!
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 43
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            return 43
        }

        func getItem(_ row: Int) -> String {
            return icon_list[row]
        }
    }

    let alert = AlertController(title: "create_marker".localized, message: nil, preferredStyle: .alert)
    let layout = UICompactStackView()
    let name = UICompactStackView()
    let name_edit = UITextField()
    let name_label = UILabel()
    let ispublic = UICompactStackView()
    let ispublic_label = UILabel()
    let ispublic_switch = UISwitch()
    let icon = UICompactStackView()
    let icon_label = UILabel()
    let icon_picker = UIPickerView()
    let pickerDelegate = PickerDelegate()

    init(_ mapController: MapController) {
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            mapController.editingMarker.name = self.name_edit.text
            mapController.editingMarker.isPublic = self.ispublic_switch.isOn
            mapController.editingMarker.attr = [Key.COLOR: self.pickerDelegate.getItem(self.icon_picker.selectedRow(inComponent: 0))]
            mapController.refreshEditing(.marker)
        }
        alert.add(action)

        func check() {
            action.isEnabled = !name_edit.text!.isEmpty
        }

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .leading
        layout.distribution = .fill
        layout.spacing = 5

        name.translatesAutoresizingMaskIntoConstraints = false
        name.axis = .horizontal
        name.alignment = .center
        name.distribution = .fill
        name.spacing = 5

        name_label.translatesAutoresizingMaskIntoConstraints = false
        name_label.adjustsFontSizeToFitWidth = false
        name_label.text = "name".localized
        name.addArrangedSubview(name_label)

        name_edit.translatesAutoresizingMaskIntoConstraints = false
        name_edit.backgroundColor = .white
        name_edit.layer.borderColor = UIColor.gray.cgColor
        name_edit.layer.borderWidth = 1
        name_edit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }
        check()
        name.addArrangedSubview(name_edit)

        layout.addArrangedSubview(name)

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
        icon_picker.widthAnchor.constraint(equalToConstant: 75).isActive = true
        icon_picker.heightAnchor.constraint(equalToConstant: 162).isActive = true
        icon.addArrangedSubview(icon_picker)

        layout.addArrangedSubview(icon)

        layout.requestLayout()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        mapController.present(alert, animated: true, completion:nil)
    }
}
