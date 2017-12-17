//
//  UIHintDialog.swift
//  whereim
//
//  Created by Buganini Q on 09/06/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class UIHintDialog: UIStackView {
    let label = UILabel()
    let actions = UIStackView()
    let close = UIButton()
    let background = UIView()
    var _key: String?
    var key: String? {
        set {
            label.text = newValue?.localized
            _key = newValue
        }
        get {
            return _key
        }
    }
    var callback: (() -> ())?

    init() {
        super.init(frame: .zero)
        setView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setView()
    }

    func setView() {
        translatesAutoresizingMaskIntoConstraints = false
        spacing = 10
        axis = .vertical
        alignment = .fill
        distribution = .fill
        layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        isLayoutMarginsRelativeArrangement = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        addArrangedSubview(label)

        actions.translatesAutoresizingMaskIntoConstraints = false
        actions.spacing = 10
        actions.axis = .vertical
        actions.alignment = .trailing
        actions.distribution = .fill

        close.translatesAutoresizingMaskIntoConstraints = false
        close.setTitle("got_it".localized, for: .normal)
        close.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        close.backgroundColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1.0)
        close.setTitleColor(UIColor.black, for: .normal)
        close.layer.cornerRadius = 5
        actions.addArrangedSubview(close)

        addArrangedSubview(actions)

        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = UIColor(red:0.27, green:0.52, blue:0.96, alpha:1.0)
        background.layer.cornerRadius = 15
        insertSubview(background, at: 0)

        background.topAnchor.constraint(equalTo: topAnchor).isActive = true
        background.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        background.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        widthAnchor.constraint(equalToConstant: 250).isActive = true

        close.addTarget(self, action: #selector(closed(sender:)), for: .touchUpInside)
    }

    @objc func closed(sender: Any) {
        UserDefaults.standard.set(true, forKey: _key!)
        if let c = callback {
            c()
        }
    }
}
