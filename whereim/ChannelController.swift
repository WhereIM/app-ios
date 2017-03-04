//
//  ChannelController.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelController: UITabBarController, ChannelListChangedListener, ConnectionStatusCallback {
    var service: CoreService?
    var channel: Channel?
    let loadingSwitch = UILoadingSwitch()
    var channelListChangedCbkey: Int?
    var connectionStatusChangedCbKey: Int?
    let layout = UICompactStackView()
    let titleLayout = UICompactStackView()
    let channelTitle = UILabel()
    let channelSubtitle = UILabel()
    let connectionStatusIndicator = UIActivityIndicatorView()
    let shareButton = UIButton()


    override func viewDidLoad() {
        service = CoreService.bind()
        channelListChangedCbkey = service?.addChannelListChangedListener(channelListChangedCbkey, self)
        connectionStatusChangedCbKey = service!.addConnectionStatusChangedListener(connectionStatusChangedCbKey, self)

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

        connectionStatusIndicator.activityIndicatorViewStyle = .gray
        connectionStatusIndicator.startAnimating()
        navigator.addSubview(connectionStatusIndicator)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setImage(UIImage(named: "icon_share"), for: .normal)
        shareButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        shareButton.addTarget(self, action: #selector(invite_join(sender:)), for: .touchUpInside)
        navigator.addSubview(shareButton)

        layout.translatesAutoresizingMaskIntoConstraints = false
        connectionStatusIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([layout.leftAnchor.constraint(equalTo: navigator.leftAnchor, constant: -30), layout.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)])
        NSLayoutConstraint.activate([shareButton.rightAnchor.constraint(equalTo: navigator.rightAnchor), shareButton.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)])
        NSLayoutConstraint.activate([connectionStatusIndicator.rightAnchor.constraint(equalTo: shareButton.leftAnchor), connectionStatusIndicator.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)])

        navigator.autoresizingMask = .flexibleWidth
        self.navigationItem.titleView = navigator

        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "Apple Color Emoji", size: 18)!, NSForegroundColorAttributeName: UIColor.orange]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.titlePositionAdjustment = UIOffsetMake(0, -10)
    }

    func invite_join(sender: UIButton) {
        print("invite_join")
        if let url = NSURL(string: "http://where.im/channel/\(channel!.id!)") {
            let objectsToShare = ["action_invite".localized, url] as [Any]
            let vc = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            vc.popoverPresentationController?.sourceView = sender
            self.present(vc, animated: true, completion: nil)
        }
    }

    deinit {
        if let sv = service {
            if channelListChangedCbkey != nil {
                sv.removeChannelListChangedListener(channelListChangedCbkey)
                channelListChangedCbkey = nil
            }
            if connectionStatusChangedCbKey != nil {
                sv.removeConnectionStatusChangedListener(connectionStatusChangedCbKey)
                connectionStatusChangedCbKey = nil
            }
        }
    }

    func channelListChanged() {
        if channel!.user_channel_name != nil && !channel!.user_channel_name!.isEmpty {
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

    func onConnectionStatusChanged(_ connected: Bool) {
        print("onConnectionStatusChanged", connected)
        connectionStatusIndicator.isHidden = connected
    }

    func switchClicked(sender: UISwitch) {
        service!.toggleChannelEnabled(channel!)
    }
}
