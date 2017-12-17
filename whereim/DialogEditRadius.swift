//
//  DialogEditRadius.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView
import UIKit

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
        alert.addAction(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "ok".localized, style: .preferred){ _ in
            let r = r_list[self.picker.selectedRow(inComponent: 0)]

            let service = CoreService.bind()
            service.setSelfRadius(channel, r)
        }
        alert.addAction(action)

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
