//
//  DialogShareLocation.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import SDCAlertView
import UIKit

class DialogShareLocation {
    let layout = UIStackView()
    let name = UIStackView()
    let name_label = UILabel()
    let name_edit = UITextField()

    init(_ viewController: UIViewController, _ location: CLLocationCoordinate2D, _ title: String?, _ view: UIView, _ touchPosition: CGPoint?) {
        let alert = AlertController(title: "share".localized, message: nil, preferredStyle: .alert)
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
                if let tp = touchPosition {
                    vc.popoverPresentationController?.sourceRect = CGRect(x: tp.x, y: tp.y, width: 0, height: 0)
                }
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
        name_edit.text = title
        name_edit.backgroundColor = .white
        name_edit.layer.borderColor = UIColor.gray.cgColor
        name_edit.layer.borderWidth = 1
        name_edit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        name_edit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        name.addArrangedSubview(name_edit)

        alert.contentView.addSubview(name)

        name.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        name.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: name.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}
