//
//  FilterBar.swift
//  whereim
//
//  Created by Buganini Q on 21/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

protocol FilterBarDelegate {
    func onFilter(keyword: String?)
}

class FilterBar: UIStackView {
    let background = UIView()
    let keyword = UITextField()
    let btn_clear = UIButton()
    var delegate: FilterBarDelegate?

    init() {
        super.init(frame: .zero)
        setView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setView()
    }

    func setView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .horizontal
        self.alignment = .leading
        self.distribution = .fill
        self.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.isLayoutMarginsRelativeArrangement = true

        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = .gray
        self.insertSubview(background, at: 0)

        background.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        background.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        background.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        keyword.translatesAutoresizingMaskIntoConstraints = false
        keyword.backgroundColor = .white
        keyword.layer.cornerRadius = 10
        keyword.addTarget(self, action: #selector(keyword_changed(sender:)), for: .editingChanged)
        self.addArrangedSubview(keyword)

        btn_clear.translatesAutoresizingMaskIntoConstraints = false
        btn_clear.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 5)
        btn_clear.setTitle("✘", for: .normal)
        btn_clear.isHidden = true
        btn_clear.addTarget(self, action: #selector(clear_clicked(sender:)), for: .touchUpInside)
        self.addArrangedSubview(btn_clear)

        keyword.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        btn_clear.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    @objc func keyword_changed(sender: Any) {
        if keyword.text != nil && !keyword.text!.isEmpty {
            if let d = delegate {
                d.onFilter(keyword: keyword.text)
            }
            btn_clear.isHidden = false
        } else {
            if let d = delegate {
                d.onFilter(keyword: nil)
            }
            btn_clear.isHidden = true
        }
    }

    @objc func clear_clicked(sender: Any) {
        btn_clear.isHidden = true
        keyword.text = ""
        keyword.resignFirstResponder()
        if let d = delegate {
            d.onFilter(keyword: nil)
        }
    }


}
