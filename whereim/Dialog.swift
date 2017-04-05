//
//  Dialog.swift
//  whereim
//
//  Created by Buganini Q on 03/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView
import UIKit

class DialogJoinChannel {
    let alert = AlertController(title: "join_channel".localized, message: nil, preferredStyle: .alert)
    let layout = UICompactStackView()
    let display_name = UICompactStackView()
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
        layout.alignment = .leading
        layout.distribution = .fill
        layout.spacing = 5

        display_name.translatesAutoresizingMaskIntoConstraints = false
        display_name.axis = .horizontal
        display_name.alignment = .center
        display_name.distribution = .fill
        display_name.spacing = 5

        display_name_label.translatesAutoresizingMaskIntoConstraints = false
        display_name_label.adjustsFontSizeToFitWidth = false
        display_name_label.text = "display_name".localized
        display_name.addArrangedSubview(display_name_label)

        display_name_edit.text = UserDefaults.standard.string(forKey: Key.NAME)
        display_name_edit.translatesAutoresizingMaskIntoConstraints = false
        display_name_edit.backgroundColor = .white
        display_name_edit.layer.borderColor = UIColor.gray.cgColor
        display_name_edit.layer.borderWidth = 1
        display_name_edit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        display_name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: display_name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }

        display_name.addArrangedSubview(display_name_edit)

        layout.addArrangedSubview(display_name)

        layout.requestLayout()

        check()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}

class DialogCreateChannel {
    let alert = AlertController(title: "create_channel".localized, message: nil, preferredStyle: .alert)
    let layout = UICompactStackView()
    let channel_name = UICompactStackView()
    let channel_name_label = UILabel()
    let channel_name_edit = UITextField()
    let display_name = UICompactStackView()
    let display_name_label = UILabel()
    let display_name_edit = UITextField()

    init(_ viewController: UIViewController) {
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            let service = CoreService.bind()
            let _channel_name = (self.channel_name_edit.text)!
            let _mate_name = (self.display_name_edit.text)!
            service.createChannel(channel_name: _channel_name, mate_name: _mate_name)
        }
        alert.add(action)

        func check() {
            action.isEnabled = !channel_name_edit.text!.isEmpty && !display_name_edit.text!.isEmpty
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

        display_name.translatesAutoresizingMaskIntoConstraints = false
        display_name.axis = .horizontal
        display_name.alignment = .center
        display_name.distribution = .fill
        display_name.spacing = 5

        display_name_label.translatesAutoresizingMaskIntoConstraints = false
        display_name_label.adjustsFontSizeToFitWidth = false
        display_name_label.text = "display_name".localized
        display_name.addArrangedSubview(display_name_label)

        display_name_edit.text = UserDefaults.standard.string(forKey: Key.NAME)
        display_name_edit.translatesAutoresizingMaskIntoConstraints = false
        display_name_edit.backgroundColor = .white
        display_name_edit.layer.borderColor = UIColor.gray.cgColor
        display_name_edit.layer.borderWidth = 1
        display_name_edit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        display_name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: display_name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }

        display_name.addArrangedSubview(display_name_edit)

        layout.addArrangedSubview(display_name)

        layout.requestLayout()

        check()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}

class DialogStartEditing {
    init(_ mapController: MapController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action_enchantment = UIAlertAction(title: "create_enchantment".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            _ = DialogCreateEnchantment(mapController)
        }

        let action_marker = UIAlertAction(title: "create_marker".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            _ = DialogCreateMarker(mapController)
        }

        alert.addAction(action_enchantment)
        alert.addAction(action_marker)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        mapController.present(alert, animated: true, completion:nil)
    }
}

class DialogCreateEnchantment {
    let alert = AlertController(title: "create_enchantment".localized, message: nil, preferredStyle: .alert)
    let layout = UICompactStackView()
    let name = UICompactStackView()
    let name_label = UILabel()
    let name_edit = UITextField()
    let ispublic = UICompactStackView()
    let ispublic_label = UILabel()
    let ispublic_switch = UISwitch()

    init(_ mapController: MapController) {
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            mapController.editingEnchantment.name = self.name_edit.text
            mapController.editingEnchantment.isPublic = self.ispublic_switch.isOn
            mapController.refreshEditing(.enchantment)
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

        ispublic.addArrangedSubview(ispublic_switch)

        layout.addArrangedSubview(ispublic)

        layout.requestLayout()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        mapController.present(alert, animated: true, completion:nil)
    }
}

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
    let icon = UICompactStackView()
    let icon_label = UILabel()
    let icon_picker = UIPickerView()
    let pickerDelegate = PickerDelegate()
    let ispublic = UICompactStackView()
    let ispublic_label = UILabel()
    let ispublic_switch = UISwitch()

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

        ispublic.translatesAutoresizingMaskIntoConstraints = false
        ispublic.axis = .horizontal
        ispublic.alignment = .center
        ispublic.distribution = .fill
        ispublic.spacing = 5

        ispublic_label.translatesAutoresizingMaskIntoConstraints = false
        ispublic_label.adjustsFontSizeToFitWidth = false
        ispublic_label.text = "is_public".localized
        ispublic.addArrangedSubview(ispublic_label)

        ispublic.addArrangedSubview(ispublic_switch)

        layout.addArrangedSubview(ispublic)

        layout.requestLayout()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        mapController.present(alert, animated: true, completion:nil)
    }
}
