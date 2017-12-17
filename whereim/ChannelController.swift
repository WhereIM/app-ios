//
//  ChannelController.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import UIKit

class ChannelController: UITabBarController, ChannelListChangedListener, ConnectionStatusCallback, MapDataReceiver {
    static let TAB_MAP = 0
    static let TAB_SEARCH = 1
    static let TAB_MESSAGE = 2
    static let TAB_MARKER = 3
    static let TAB_ENCHANTMENT = 4

    let service = CoreService.bind()
    var channel: Channel?
    var defaultTab = 0
    let loadingSwitch = UILoadingSwitch()
    var mapCbKey: Int?
    var channelListChangedCbKey: Int?
    var connectionStatusChangedCbKey: Int?
    let layout = UIStackView()
    let titleLayout = UIStackView()
    let channelTitle = UILabel()
    let channelSubtitle = UILabel()
    let connectionStatusIndicator = UIActivityIndicatorView()
    let shareButton = UIButton()
    var mapController: MapController?
    let cover = UIView()
    let toggleChannelPointer = UIImageView()
    var toggleChannelPointerLeft: NSLayoutConstraint?
    let toggleChannelDesc = UIHintDialog()
    let invitePointer = UIImageView()
    let inviteDesc = UIHintDialog()

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
            mc.moveTo(mate: mate, focus: true)
            if mate.latitude != nil {
                self.selectedIndex = 0
            }
        }
    }

    func moveTo(enchantment: Enchantment) {
        if let mc = mapController {
            mc.moveTo(enchantment: enchantment, focus: true)
            self.selectedIndex = 0
        }
    }

    func moveTo(marker: Marker) {
        if let mc = mapController {
            mc.moveTo(marker: marker, focus: true)
            self.selectedIndex = 0
        }
    }

    func edit(enchantment: Enchantment, name: String, shared: Bool) {
        if let mc = mapController {
            mc.edit(enchantment: enchantment, name: name, shared: shared)
            self.selectedIndex = 0
        }
    }

    func edit(marker: Marker, name: String, attr: [String:Any], shared: Bool) {
        if let mc = mapController {
            mc.edit(marker: marker, name: name, attr: attr, shared: shared)
            self.selectedIndex = 0
        }
    }

    override func viewDidLoad() {
        let navigator = UINavigatorTitleView(frame: (self.navigationController?.navigationBar.bounds)!)

        layout.axis = .horizontal
        layout.alignment = .center
        layout.distribution = .fill
        layout.spacing = 10

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
        NSLayoutConstraint.activate([layout.leftAnchor.constraint(equalTo: navigator.leftAnchor, constant: 0), layout.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)])
        NSLayoutConstraint.activate([shareButton.rightAnchor.constraint(equalTo: navigator.rightAnchor), shareButton.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)])
        NSLayoutConstraint.activate([connectionStatusIndicator.rightAnchor.constraint(equalTo: shareButton.leftAnchor, constant: -5), connectionStatusIndicator.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)])

        self.navigationItem.titleView = navigator

        let appearance = UITabBarItem.appearance()
        let attributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font:UIFont(name: "Apple Color Emoji", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor.orange]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.titlePositionAdjustment = UIOffsetMake(0, -10)

        selectedIndex = defaultTab

        super.viewDidLoad()

        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.isExclusiveTouch = true
        cover.isUserInteractionEnabled = true
        self.view.addSubview(cover)
        self.view.bringSubview(toFront: cover)
        cover.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        cover.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        cover.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        cover.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        cover.isHidden = true

        toggleChannelPointer.translatesAutoresizingMaskIntoConstraints = false
        toggleChannelPointer.image = UIImage(named: "pointer_up")
        self.view.addSubview(toggleChannelPointer)
        self.view.bringSubview(toFront: toggleChannelPointer)
        toggleChannelPointer.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 5).isActive = true
        toggleChannelPointerLeft = toggleChannelPointer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        toggleChannelPointerLeft!.isActive = true
        toggleChannelPointer.isHidden = true

        toggleChannelDesc.translatesAutoresizingMaskIntoConstraints = false
        toggleChannelDesc.key = Key.TIP_TOGGLE_CHANNEL_2
        toggleChannelDesc.callback = checkTips
        self.view.addSubview(toggleChannelDesc)
        self.view.bringSubview(toFront: toggleChannelDesc)
        toggleChannelDesc.topAnchor.constraint(equalTo: toggleChannelPointer.bottomAnchor).isActive = true
        toggleChannelDesc.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        toggleChannelDesc.isHidden = true

        invitePointer.translatesAutoresizingMaskIntoConstraints = false
        invitePointer.image = UIImage(named: "pointer_up_right")
        self.view.addSubview(invitePointer)
        self.view.bringSubview(toFront: invitePointer)
        invitePointer.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 5).isActive = true
        invitePointer.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -42).isActive = true
        invitePointer.isHidden = true

        inviteDesc.translatesAutoresizingMaskIntoConstraints = false
        inviteDesc.key = Key.TIP_INVITE
        inviteDesc.callback = checkTips
        self.view.addSubview(inviteDesc)
        self.view.bringSubview(toFront: inviteDesc)
        inviteDesc.topAnchor.constraint(equalTo: invitePointer.bottomAnchor).isActive = true
        inviteDesc.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        inviteDesc.isHidden = true
    }

    func checkTips() {
        cover.isHidden = true
        toggleChannelPointer.isHidden = true
        toggleChannelDesc.isHidden = true
        invitePointer.isHidden = true
        inviteDesc.isHidden = true

        if UserDefaults.standard.bool(forKey: Key.TIP_TOGGLE_CHANNEL_2) != true {
            toggleChannelPointer.isHidden = false
            toggleChannelDesc.isHidden = false
            cover.isHidden = false
            return
        }

        if UserDefaults.standard.bool(forKey: Key.TIP_INVITE) != true {
            invitePointer.isHidden = false
            inviteDesc.isHidden = false
            cover.isHidden = false
            return
        }
    }

    @objc func invite_join(sender: UIButton) {
        _ = DialogChannelInvite(self, sender, channel!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        service.setViewController(self)
        mapCbKey = service.openMap(channel!, mapCbKey, self)
        channelListChangedCbKey = service.addChannelListChangedListener(channelListChangedCbKey, self)
        connectionStatusChangedCbKey = service.addConnectionStatusChangedListener(connectionStatusChangedCbKey, self)

        checkTips()
    }

    override func viewWillDisappear(_ animated: Bool) {
        service.setViewController(nil)
        if channelListChangedCbKey != nil {
            service.removeChannelListChangedListener(channelListChangedCbKey)
            channelListChangedCbKey = nil
        }
        if connectionStatusChangedCbKey != nil {
            service.removeConnectionStatusChangedListener(connectionStatusChangedCbKey)
            connectionStatusChangedCbKey = nil
        }
        if mapCbKey != nil{
            service.closeMap(channel: channel!, key: mapCbKey!)
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

        toggleChannelPointerLeft?.constant = 61 - 30 + max(channelTitle.intrinsicContentSize.width, channelSubtitle.intrinsicContentSize.width) + layout.spacing
    }

    func onConnectionStatusChanged(_ connected: Bool) {
        if connected {
            connectionStatusIndicator.stopAnimating()
        } else {
            connectionStatusIndicator.startAnimating()
        }
    }

    @objc func switchClicked(sender: UISwitch) {
        service.toggleChannelActive(channel!)
    }

    func onMateData(_ mate: Mate) {
        if let mc = mapController {
            mc.onMateData(mate)
        }
    }

    func onEnchantmentData(_ enchantment: Enchantment) {
        if let mc = mapController {
            mc.onEnchantmentData(enchantment)
        }
    }
    func onMarkerData(_ marker: Marker) {
        if let mc = mapController {
            mc.onMarkerData(marker)
        }
    }
}
