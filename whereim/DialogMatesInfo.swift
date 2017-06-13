//
//  DialogMatesInfo.swift
//  whereim
//
//  Created by Buganini Q on 14/06/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView
import UIKit

class DialogMatesInfo {
    let alert = AlertController(title: "location_status".localized, message: nil, preferredStyle: .alert)
    let layout = UIStackView()

    let not_avail = UIStackView()
    let not_avail_ic = UILabel()
    let not_avail_desc = UILabel()

    let stale = UIStackView()
    let stale_ic = UILabel()
    let stale_desc = UILabel()

    let fresh = UIStackView()
    let fresh_ic = UILabel()
    let fresh_desc = UILabel()

    init(_ viewController: UIViewController) {
        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .leading
        layout.distribution = .fill
        layout.spacing = 10

        not_avail.translatesAutoresizingMaskIntoConstraints = false
        not_avail.axis = .horizontal
        not_avail.alignment = .center
        not_avail.distribution = .fill
        not_avail.spacing = 10
        layout.addArrangedSubview(not_avail)

        not_avail_ic.translatesAutoresizingMaskIntoConstraints = false
        not_avail_ic.text = "•"
        not_avail_ic.textColor = UIColor(red:0.50, green:0.50, blue:0.50, alpha:1.0)
        not_avail.addArrangedSubview(not_avail_ic)

        not_avail_desc.translatesAutoresizingMaskIntoConstraints = false
        not_avail_desc.text = "location_status_not_avail".localized
        not_avail.addArrangedSubview(not_avail_desc)

        stale.translatesAutoresizingMaskIntoConstraints = false
        stale.axis = .horizontal
        stale.alignment = .center
        stale.distribution = .fill
        stale.spacing = 10
        layout.addArrangedSubview(stale)

        stale_ic.translatesAutoresizingMaskIntoConstraints = false
        stale_ic.text = "•"
        stale_ic.textColor = UIColor(red:1.00, green:0.50, blue:0.00, alpha:1.0)
        stale.addArrangedSubview(stale_ic)

        stale_desc.translatesAutoresizingMaskIntoConstraints = false
        stale_desc.text = "location_status_stale".localized
        stale.addArrangedSubview(stale_desc)

        fresh.translatesAutoresizingMaskIntoConstraints = false
        fresh.axis = .horizontal
        fresh.alignment = .center
        fresh.distribution = .fill
        fresh.spacing = 10
        layout.addArrangedSubview(fresh)

        fresh_ic.translatesAutoresizingMaskIntoConstraints = false
        fresh_ic.text = "•"
        fresh_ic.textColor = UIColor(red:0.00, green:1.00, blue:0.00, alpha:1.0)
        fresh.addArrangedSubview(fresh_ic)

        fresh_desc.translatesAutoresizingMaskIntoConstraints = false
        fresh_desc.text = "location_status_fresh".localized
        fresh.addArrangedSubview(fresh_desc)

        alert.contentView.addSubview(layout)

        layout.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: layout.bottomAnchor).isActive = true

        alert.add(AlertAction(title: "close".localized, style: .normal, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
