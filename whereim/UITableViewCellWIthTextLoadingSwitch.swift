//
//  UITableViewCellWIthTextLoadingSwitch.swift
//  whereim
//
//  Created by Buganini Q on 25/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class UITableViewCellWIthTextLoadingSwitch: UITableViewCell {
    let title = UILabel()
    let loadingSwitch = UILoadingSwitch()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        title.adjustsFontSizeToFitWidth = false
        title.translatesAutoresizingMaskIntoConstraints = false

        loadingSwitch.requestLayout()
        loadingSwitch.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(title)
        self.contentView.addSubview(loadingSwitch)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:15),
            title.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
        NSLayoutConstraint.activate([
            loadingSwitch.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant:-15),
            loadingSwitch.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
