//
//  UIPlacerHolderCell.swift
//  whereim
//
//  Created by Buganini Q on 12/04/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

//
//  UIPlaceHolder.swift
//  whereim
//
//  Created by Buganini Q on 12/04/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class UIPlaceHolderCell: UITableViewCell {
    let label = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(12)
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = false

        self.contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
