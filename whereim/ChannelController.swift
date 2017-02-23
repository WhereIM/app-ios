//
//  ChannelController.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelController: UITabBarController {
    var channel: Channel?

    override func viewDidLoad() {
        let navigator = UIView(frame: (self.navigationController?.navigationBar.bounds)!)

        let layout = UICompactStackView()
        layout.axis = .horizontal
        layout.alignment = .center
        layout.distribution = .fill
        layout.spacing = 50

        let titleLayout = UICompactStackView()
        titleLayout.axis = .vertical
        titleLayout.alignment = .leading
        titleLayout.distribution = .fill

        if channel!.user_channel_name != nil {
            let title = UILabel()
            title.adjustsFontSizeToFitWidth = false
            title.text = channel!.user_channel_name
            titleLayout.addArrangedSubview(title)

            let subtitle = UILabel()
            subtitle.font = subtitle.font.withSize(12)
            subtitle.adjustsFontSizeToFitWidth = false
            subtitle.text = channel!.channel_name
            titleLayout.addArrangedSubview(subtitle)
        } else {
            let title = UILabel()
            title.adjustsFontSizeToFitWidth = false
            title.text = channel!.channel_name
            titleLayout.addArrangedSubview(title)
        }

        layout.addArrangedSubview(titleLayout)

        let switchContainer = UILoadingSwitch()
        switchContainer.setEnabled(true)
        layout.addArrangedSubview(switchContainer)

        layout.requestLayout()

        navigator.addSubview(layout)

        let connectionStatusIndicator = UIActivityIndicatorView()
        connectionStatusIndicator.activityIndicatorViewStyle = .gray
        connectionStatusIndicator.startAnimating()
        navigator.addSubview(connectionStatusIndicator)

        layout.translatesAutoresizingMaskIntoConstraints = false
        connectionStatusIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([layout.leftAnchor.constraint(equalTo: navigator.leftAnchor, constant: -30), layout.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)])
        NSLayoutConstraint.activate([connectionStatusIndicator.rightAnchor.constraint(equalTo: navigator.rightAnchor), connectionStatusIndicator.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)])

        self.navigationItem.titleView = navigator
    }
}
