//
//  ChannelController.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import UIKit

class ChannelController: UITabBarController, ChannelListChangedListener, ConnectionStatusCallback {
    static let TAB_MAP = 0
    static let TAB_SEARCH = 1
    static let TAB_MESSAGE = 2
    static let TAB_MARKER = 3
    static let TAB_ENCHANTMENT = 4

    let service = CoreService.bind()
    var channel: Channel?
    var defaultTab = 0
    let loadingSwitch = UILoadingSwitch()
    var channelListChangedCbkey: Int?
    var connectionStatusChangedCbKey: Int?
    let layout = UIStackView()
    let titleLayout = UIStackView()
    let channelTitle = UILabel()
    let channelSubtitle = UILabel()
    let connectionStatusIndicator = UIActivityIndicatorView()
    let shareButton = UIButton()
    var mapController: MapController?

    func setMapCtrl(_ mc: MapController) {
        mapController = mc
    }

    func getMapCenter() -> CLLocationCoordinate2D {
        if let mc = mapController {
            return mc.getMapCenter()
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    func setSearchResults(_ results: [POI]) {
        if let mc = mapController {
            mc.setSearchResults(results)
        }
    }

    func moveToSearchResult(at: Int) {
        if let mc = mapController {
            mc.moveToSearchResult(at: at)
            self.selectedIndex = 0
        }
    }

    func moveTo(mate: Mate) {
        if let mc = mapController {
            mc.moveTo(mate: mate)
            if mate.latitude != nil {
                self.selectedIndex = 0
            }
        }
    }

    func moveTo(enchantment: Enchantment) {
        if let mc = mapController {
            mc.moveTo(enchantment: enchantment)
            self.selectedIndex = 0
        }
    }

    func moveTo(marker: Marker) {
        if let mc = mapController {
            mc.moveTo(marker: marker)
            self.selectedIndex = 0
        }
    }

    override func viewDidLoad() {
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

        navigator.addSubview(layout)

        connectionStatusIndicator.activityIndicatorViewStyle = .gray
        connectionStatusIndicator.hidesWhenStopped = true
        connectionStatusIndicator.stopAnimating()
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
        NSLayoutConstraint.activate([connectionStatusIndicator.rightAnchor.constraint(equalTo: shareButton.leftAnchor, constant: -5), connectionStatusIndicator.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)])

        navigator.autoresizingMask = .flexibleWidth
        self.navigationItem.titleView = navigator

        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "Apple Color Emoji", size: 18)!, NSForegroundColorAttributeName: UIColor.orange]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.titlePositionAdjustment = UIOffsetMake(0, -10)

        selectedIndex = defaultTab
    }

    func invite_join(sender: UIButton) {
        _ = DialogChannelInvite(self, sender, channel!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        service.setViewController(self)
        channelListChangedCbkey = service.addChannelListChangedListener(channelListChangedCbkey, self)
        connectionStatusChangedCbKey = service.addConnectionStatusChangedListener(connectionStatusChangedCbKey, self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        service.setViewController(nil)
        if channelListChangedCbkey != nil {
            service.removeChannelListChangedListener(channelListChangedCbkey)
            channelListChangedCbkey = nil
        }
        if connectionStatusChangedCbKey != nil {
            service.removeConnectionStatusChangedListener(connectionStatusChangedCbKey)
            connectionStatusChangedCbKey = nil
        }
        super.viewWillDisappear(animated)
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
        loadingSwitch.setEnabled(channel!.active)
    }

    func onConnectionStatusChanged(_ connected: Bool) {
        if connected {
            connectionStatusIndicator.stopAnimating()
        } else {
            connectionStatusIndicator.startAnimating()
        }
    }

    func switchClicked(sender: UISwitch) {
        service.toggleChannelActive(channel!)
    }
}
