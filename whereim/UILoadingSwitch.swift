//
//  UILoadingSwitch.swift
//  whereim
//
//  Created by Buganini Q on 23/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class UILoadingSwitch: UIFrameView {
    let uiswitch = UISwitch()
    let loading = UIActivityIndicatorView()

    init() {
        super.init(frame: .zero)
        setView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setView()
    }

    func setView() {
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.activityIndicatorViewStyle = .gray
        loading.hidesWhenStopped = true
        addSubview(uiswitch)
        addSubview(loading)
        NSLayoutConstraint.activate([
            uiswitch.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            uiswitch.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        NSLayoutConstraint.activate([
            loading.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
    }

    func setEnabled(_ enable: Bool?) {
        if enable == nil {
            uiswitch.isHidden = true
            loading.startAnimating()
        } else if enable == true {
            loading.stopAnimating()
            uiswitch.isHidden = false
            uiswitch.setOn(true, animated: false)
        } else if enable == false {
            loading.stopAnimating()
            uiswitch.isHidden = false
            uiswitch.setOn(false, animated: false)
        }
    }
}
