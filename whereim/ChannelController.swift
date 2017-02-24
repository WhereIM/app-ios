//
//  ChannelController.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelController: UITabBarController, ChannelListChangedListener {
    var service: CoreService?
    var channel: Channel?
    let loadingSwitch = UILoadingSwitch()
    var cbkey: Int?
    let layout = UICompactStackView()
    let titleLayout = UICompactStackView()
    let channelTitle = UILabel()
    let channelSubtitle = UILabel()


    override func viewDidLoad() {
        service = CoreService.bind()
        cbkey = service?.addChannelListChangedListener(self)

        let navigator = UIView(frame: (self.navigationController?.navigationBar.bounds)!)

        layout.axis = .horizontal
        layout.alignment = .center
        layout.distribution = .fill
        layout.spacing = 50

        titleLayout.axis = .vertical
        titleLayout.alignment = .leading
        titleLayout.distribution = .fill

        channelTitle.adjustsFontSizeToFitWidth = false

        channelSubtitle.font = channelSubtitle.font.withSize(12)
        channelSubtitle.adjustsFontSizeToFitWidth = false

        titleLayout.addArrangedSubview(channelTitle)
        titleLayout.addArrangedSubview(channelSubtitle)

        layout.addArrangedSubview(titleLayout)

        loadingSwitch.uiswitch.addTarget(self, action: #selector(switchClicked(sender:)), for: UIControlEvents.touchUpInside)
        layout.addArrangedSubview(loadingSwitch)

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

        navigator.autoresizingMask = .flexibleWidth
        self.navigationItem.titleView = navigator
    }

    deinit {
        if cbkey != nil {
            service!.removeChannelListChangedListener(cbkey)
        }
    }

    func channelListChanged() {
        if channel!.user_channel_name != nil {
            channelTitle.text = channel!.user_channel_name

            channelSubtitle.text = channel!.channel_name
            channelSubtitle.isHidden = false
        } else {
            channelTitle.text = channel!.channel_name

            channelSubtitle.isHidden = true
        }
        loadingSwitch.setEnabled(channel!.enable)
        layout.requestLayout()
    }

    func switchClicked(sender: UISwitch) {
        service!.toggleChannelEnabled(channel!)
    }
}
