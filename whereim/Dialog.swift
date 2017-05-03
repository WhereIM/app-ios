//
//  Dialog.swift
//  whereim
//
//  Created by Buganini Q on 03/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import SDCAlertView
import UIKit


class DialogMenu {
    init(_ viewController: UIViewController, _ sourceView: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action_settings = UIAlertAction(title: "action_settings".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "settings")
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "action_settings".localized, style: .plain, target: nil, action: nil)
            viewController.navigationController?.pushViewController(vc!, animated: true)
        }

        let action_about = UIAlertAction(title: "action_about".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "about")
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "action_about".localized, style: .plain, target: nil, action: nil)
            viewController.navigationController?.pushViewController(vc!, animated: true)
        }

        alert.addAction(action_settings)
        alert.addAction(action_about)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = sourceView
        viewController.present(alert, animated: true, completion:nil)
    }
}

class DialogEditSelf {
    let alert = AlertController(title: nil, message: nil, preferredStyle: .alert)
    let layout = UICompactStackView()
    let mate_name = UICompactStackView()
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
        layout.alignment = .leading
        layout.distribution = .fill
        layout.spacing = 5

        mate_name.translatesAutoresizingMaskIntoConstraints = false
        mate_name.axis = .horizontal
        mate_name.alignment = .center
        mate_name.distribution = .fill
        mate_name.spacing = 5

        mate_name_label.translatesAutoresizingMaskIntoConstraints = false
        mate_name_label.adjustsFontSizeToFitWidth = false
        mate_name_label.text = "name".localized
        mate_name.addArrangedSubview(mate_name_label)

        mate_name_edit.text = mate.mate_name
        mate_name_edit.translatesAutoresizingMaskIntoConstraints = false
        mate_name_edit.backgroundColor = .white
        mate_name_edit.layer.borderColor = UIColor.gray.cgColor
        mate_name_edit.layer.borderWidth = 1
        mate_name_edit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        mate_name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: mate_name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }

        mate_name.addArrangedSubview(mate_name_edit)

        layout.addArrangedSubview(mate_name)

        layout.requestLayout()

        check()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}

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

class DialogRequestActiveDevice {
    init(_ viewController: UIViewController) {
        let alert = UIAlertController(title: "active_client".localized, message: "active_client_message".localized, preferredStyle: .alert)
        let action_ok = UIAlertAction(title: "ok".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let service = CoreService.bind()
            service.setActive()
        }

        alert.addAction(action_ok)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion:nil)
    }
}

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

class DialogDeleteChannel {
    init(_ viewController: UIViewController, _ channel: Channel) {
        let alert = UIAlertController(title: "leave_channel".localized, message: channel.getName(), preferredStyle: .alert)

        let action_leave = UIAlertAction(title: "leave".localized, style: .destructive) { (alert: UIAlertAction!) -> Void in
            let service = CoreService.bind()
            service.deleteChannel(channel)
        }

        alert.addAction(action_leave)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion:nil)
    }
}

class DialogEditRadius {
    class PickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var radius_list: [Int]?

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return radius_list!.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return String(format: "radius_m".localized, radius_list![row])
        }
    }

    let alert = AlertController(title: nil, message: nil, preferredStyle: .alert)
    let picker = UIPickerView()
    let pickerDelegate = PickerDelegate()

    init(_ viewController: UIViewController, _ channel: Channel) {
        var r_list = [Int]()
        var add = true
        for r in Config.SELF_RADIUS {
            r_list.append(r)
            if r == channel.radius! {
                add = false
            }
        }
        if add {
            r_list.append(channel.radius!)
        }
        r_list.sort()
        pickerDelegate.radius_list = r_list
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            let r = r_list[self.picker.selectedRow(inComponent: 0)]

            let service = CoreService.bind()
            service.setSelfRadius(channel, r)
        }
        alert.add(action)

        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = pickerDelegate
        picker.delegate = pickerDelegate
        picker.showsSelectionIndicator = true
        picker.heightAnchor.constraint(equalToConstant: 162).isActive = true

        alert.contentView.addSubview(picker)

        picker.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        picker.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: picker.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion:nil)
    }
}

class DialogStartEditing {
    init(_ mapController: MapController, _ mapView: UIView, _ touchPosition: CGPoint) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action_share = UIAlertAction(title: "share_location".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let location = mapController.editingCoordinate
            _ = DialogShareLocation(mapController, location, mapView, touchPosition)
        }

        let action_enchantment = UIAlertAction(title: "create_enchantment".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            _ = DialogCreateEnchantment(mapController)
        }

        let action_marker = UIAlertAction(title: "create_marker".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            _ = DialogCreateMarker(mapController)
        }

        let action_forge = UIAlertAction(title: "forge_location".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let service = CoreService.bind()
            service.forgeLocation(channel: mapController.channel!, location: mapController.editingCoordinate)
        }

        alert.addAction(action_share)
        alert.addAction(action_enchantment)
        alert.addAction(action_marker)
        alert.addAction(action_forge)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = mapView
        alert.popoverPresentationController?.sourceRect = CGRect(x: touchPosition.x, y: touchPosition.y, width: 0, height: 0)
        mapController.present(alert, animated: true, completion:nil)
    }
}

class DialogShareLocation {
    let layout = UICompactStackView()
    let name = UICompactStackView()
    let name_label = UILabel()
    let name_edit = UITextField()

    init(_ viewController: UIViewController, _ location: CLLocationCoordinate2D, _ view: UIView, _ touchPosition: CGPoint) {
        let alert = AlertController(title: "share_location".localized, message: nil, preferredStyle: .alert)
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            var surl = "here/\(location.latitude)/\(location.longitude)"
            var name = self.name_edit.text
            if name != nil && !name!.trim().isEmpty {
                name = name!.trim()
                surl = surl + "/" + name!.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            }
            if let url = NSURL(string: String(format: Config.WHERE_IM_URL, surl)) {
                var objectsToShare = [url] as [Any]
                if name != nil {
                    objectsToShare.insert(name!, at: 0)
                }
                let vc = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                vc.popoverPresentationController?.sourceView = view
                vc.popoverPresentationController?.sourceRect = CGRect(x: touchPosition.x, y: touchPosition.y, width: 0, height: 0)
                viewController.present(vc, animated: true, completion: nil)
            }

        }
        alert.add(action)

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
        name.addArrangedSubview(name_edit)

        name.requestLayout()

        alert.contentView.addSubview(name)

        name.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        name.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: name.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
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

        mapController.present(alert, animated: true, completion: nil)
    }
}

class DialogEditEnchantment {
    let alert = AlertController(title: nil, message: nil, preferredStyle: .alert)
    let layout = UICompactStackView()
    let name = UICompactStackView()
    let name_label = UILabel()
    let name_edit = UITextField()

    init(_ viewController: UIViewController, _ enchantment: Enchantment) {
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            let service = CoreService.bind()
            let name = (self.name_edit.text)!
            service.updateEnchantment(enchantment, [Key.NAME: name])
        }
        alert.add(action)

        func check(){
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

        name_edit.text = enchantment.name
        name_edit.translatesAutoresizingMaskIntoConstraints = false
        name_edit.backgroundColor = .white
        name_edit.layer.borderColor = UIColor.gray.cgColor
        name_edit.layer.borderWidth = 1
        name_edit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }

        name.addArrangedSubview(name_edit)

        layout.addArrangedSubview(name)

        layout.requestLayout()

        check()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}

class DialogDeleteEnchantment {
    init(_ viewController: UIViewController, _ enchantment: Enchantment) {
        let alert = UIAlertController(title: "delete".localized, message: enchantment.name, preferredStyle: .alert)

        let action_leave = UIAlertAction(title: "delete".localized, style: .destructive) { (alert: UIAlertAction!) -> Void in
            let service = CoreService.bind()
            service.deleteEnchantment(enchantment)
        }

        alert.addAction(action_leave)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion:nil)
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

class DialogEditMarker {
    let alert = AlertController(title: nil, message: nil, preferredStyle: .alert)
    let layout = UICompactStackView()
    let name = UICompactStackView()
    let name_label = UILabel()
    let name_edit = UITextField()

    init(_ viewController: UIViewController, _ marker: Marker) {
        alert.add(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            let service = CoreService.bind()
            let name = (self.name_edit.text)!
            service.updateMarker(marker, [Key.NAME: name])
        }
        alert.add(action)

        func check(){
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

        name_edit.text = marker.name
        name_edit.translatesAutoresizingMaskIntoConstraints = false
        name_edit.backgroundColor = .white
        name_edit.layer.borderColor = UIColor.gray.cgColor
        name_edit.layer.borderWidth = 1
        name_edit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: name_edit, queue: OperationQueue.main) { (notification) in
            check()
        }

        name.addArrangedSubview(name_edit)

        layout.addArrangedSubview(name)

        layout.requestLayout()

        check()

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}

class DialogDeleteMarker {
    init(_ viewController: UIViewController, _ marker: Marker) {
        let alert = UIAlertController(title: "delete".localized, message: marker.name, preferredStyle: .alert)

        let action_leave = UIAlertAction(title: "delete".localized, style: .destructive) { (alert: UIAlertAction!) -> Void in
            let service = CoreService.bind()
            service.deleteMarker(marker)
        }

        alert.addAction(action_leave)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion:nil)
    }
}
