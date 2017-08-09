//
//  ChannelListController.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelCell: UITableViewCell {
    let titleLayout = UIStackView()
    let indicator = UILabel()
    let title = UILabel()
    let subtitle = UILabel()
    let loadingSwitch = UILoadingSwitch()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none

        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.adjustsFontSizeToFitWidth = false
        indicator.text = "•"
        indicator.textColor = UIColor.red
        indicator.isHidden = true

        titleLayout.axis = .vertical
        titleLayout.alignment = .leading
        titleLayout.distribution = .fill

        title.adjustsFontSizeToFitWidth = false
        titleLayout.addArrangedSubview(title)

        subtitle.font = subtitle.font.withSize(12)
        subtitle.adjustsFontSizeToFitWidth = false
        titleLayout.addArrangedSubview(subtitle)

        titleLayout.translatesAutoresizingMaskIntoConstraints = false
        loadingSwitch.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(indicator)
        self.contentView.addSubview(titleLayout)
        self.contentView.addSubview(loadingSwitch)

        self.contentView.leftAnchor.constraint(equalTo: indicator.leftAnchor, constant: -10).isActive = true
        self.contentView.centerYAnchor.constraint(equalTo: indicator.centerYAnchor).isActive = true

        indicator.rightAnchor.constraint(equalTo: titleLayout.leftAnchor, constant: -10).isActive = true
        self.contentView.centerYAnchor.constraint(equalTo: titleLayout.centerYAnchor).isActive = true

        self.contentView.rightAnchor.constraint(equalTo: loadingSwitch.rightAnchor, constant: 10).isActive = true
        self.contentView.centerYAnchor.constraint(equalTo: loadingSwitch.centerYAnchor).isActive = true
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.layer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        } else {
            self.layer.backgroundColor = UIColor.clear.cgColor

        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChannelListAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    static let PADDING_ROWS = 2
    var channelList: [Channel]
    let service: CoreService
    let vc: ChannelListController

    init(_ service: CoreService, _ viewcontroller: ChannelListController) {
        self.service = service
        self.channelList = service.getChannelList()
        self.vc = viewcontroller
    }

    func reload() {
        self.channelList = service.getChannelList()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelList.count + ChannelListAdapter.PADDING_ROWS
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channel", for: indexPath) as! ChannelCell
        cell.backgroundColor = UIColor.clear

        if indexPath.row >= channelList.count {
            cell.titleLayout.isHidden = true
            cell.loadingSwitch.isHidden = true
            return cell
        } else {
            cell.titleLayout.isHidden = false
            cell.loadingSwitch.isHidden = false
        }

        let channel = getChannel(indexPath.row)

        if channel.enabled==true && channel.unread {
            cell.indicator.isHidden = false
        } else {
            cell.indicator.isHidden = true
        }

        if channel.user_channel_name != nil && !channel.user_channel_name!.isEmpty {
            cell.title.text = channel.user_channel_name
            cell.subtitle.text = channel.channel_name
            cell.subtitle.isHidden = false
        } else {
            cell.title.text = channel.channel_name
            cell.subtitle.text = nil
            cell.subtitle.isHidden = true
        }

        cell.loadingSwitch.uiswitch.tag = indexPath.row
        cell.loadingSwitch.uiswitch.addTarget(self, action: #selector(switchClicked(sender:)), for: UIControlEvents.touchUpInside)
        cell.loadingSwitch.setEnabled(channel.active)

        if channel.enabled == true {
            cell.loadingSwitch.isHidden = false
        } else {
            cell.loadingSwitch.isHidden = true
        }

        if indexPath.row == 0 {
            if let c = self.vc.toggleChannelPointerRight {
                c.isActive = false
            }
            self.vc.toggleChannelPointerRight = self.vc.toggleChannelPointer.rightAnchor.constraint(equalTo: cell.loadingSwitch.leftAnchor)
            self.vc.toggleChannelPointerRight!.isActive = true

            if let c = self.vc.toggleChannelPointerTop {
                c.isActive = false
            }
            self.vc.toggleChannelPointerTop = self.vc.toggleChannelPointer.topAnchor.constraint(equalTo: cell.loadingSwitch.bottomAnchor)
            self.vc.toggleChannelPointerTop!.isActive = true

            if let c = self.vc.enterChannelPointerTop {
                c.isActive = false
            }
            self.vc.enterChannelPointerTop = self.vc.enterChannelPointer.topAnchor.constraint(equalTo: cell.loadingSwitch.bottomAnchor, constant: -5)
            self.vc.enterChannelPointerTop!.isActive = true

            if let c = self.vc.enterChannelPointerCenter {
                c.isActive = false
            }
            self.vc.enterChannelPointerCenter = self.vc.enterChannelPointer.centerXAnchor.constraint(equalTo: cell.centerXAnchor)
            self.vc.enterChannelPointerCenter!.isActive = true

            DispatchQueue.main.async {
                self.vc.checkTips()
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let channel = getChannel(indexPath.row)
        let leave = UITableViewRowAction(style: .destructive, title: "✖", handler: {(action, indexPath) -> Void in
            tableView.setEditing(false, animated: true)
            _ = DialogDeleteChannel(self.vc, channel)
        })
        let edit = UITableViewRowAction(style: .normal, title: "✏️", handler: {(action, indexPath) -> Void in
            tableView.setEditing(false, animated: true)

            _ = DialogEditChannel(self.vc, channel)
        })
//        let archive = UITableViewRowAction(style: .normal, title: nil, handler: {(action, indexPath) -> Void in
//            tableView.setEditing(false, animated: true)
//
//            self.service.toggleChannelEnabled(channel)
//        })
//        if channel.enabled == true {
//            archive.title = "🔒"
//        } else {
//            archive.title = "🔓"
//        }
        return [
            leave,
//            archive,
            edit
        ]
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < channelList.count {
            return true
        }
        return false
    }

    func switchClicked(sender: UISwitch) {
        let channel = channelList[sender.tag]
        service.toggleChannelActive(channel)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row < channelList.count {
            return indexPath
        }
        return nil
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < channelList.count {
            return true
        }
        return false
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = getChannel(indexPath.row)
        if channel.enabled == true {
            self.vc.performSegue(withIdentifier: "enter_channel", sender: self)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func getChannel(_ index: Int) -> Channel {
        return channelList[index]
    }
}

class PendingPoiViewHolder: UIStackView {
    let title = UILabel()
    let desc = UILabel()

    init() {
        super.init(frame: CGRect.zero)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .horizontal
        self.alignment = .leading
        self.distribution = .fill

        let marker = UIImageView()
        marker.image = UIImage(named: "icon_marker_red")
        self.addArrangedSubview(marker)

        let layout = UIStackView()
        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .leading
        layout.distribution = .fill

        self.addArrangedSubview(layout)

        title.translatesAutoresizingMaskIntoConstraints = false
        title.adjustsFontSizeToFitWidth = false
        layout.addArrangedSubview(title)

        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.adjustsFontSizeToFitWidth = false
        layout.addArrangedSubview(desc)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPOI(poi: POI) {
        if let name = poi.name {
            title.text = name
            title.isHidden = false
        } else {
            title.isHidden = true
        }
        desc.text = String(format: "%f,%f", poi.location!.latitude, poi.location!.longitude)
    }

}

class ChannelListController: UIViewController, ChannelListChangedListener, ConnectionStatusCallback {
    var service: CoreService?
    var channelListChangedCbkey: Int?
    var connectionStatusChangedCbKey: Int?
    let menu = UIButton()

    let background = UIImageView()
    let layout = UIStackView()
    let listArea = UIView()
    let pendingArea = UIView()
    let channelListView = UITableView()
    let fab = UIButton()
    let pendingPOILayout = PendingPoiViewHolder()

    let cover = UIView()
    let newChannelPointer = UIImageView()
    let newChannelDesc = UIHintDialog()
    let toggleChannelPointer = UIImageView()
    let toggleChannelDesc = UIHintDialog()
    weak var toggleChannelPointerRight: NSLayoutConstraint?
    weak var toggleChannelPointerTop: NSLayoutConstraint?
    let enterChannelPointer = UIImageView()
    let enterChannelDesc = UIHintDialog()
    weak var enterChannelPointerTop: NSLayoutConstraint?
    weak var enterChannelPointerCenter: NSLayoutConstraint?

    let connectionStatusIndicator = UIActivityIndicatorView()
    var adapter: ChannelListAdapter?
    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()

        let navigator = UIView(frame: (self.navigationController?.navigationBar.bounds)!)
        self.navigationController?.navigationBar.barTintColor = UIColor.white

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.adjustsFontSizeToFitWidth = false
        title.text = "Where.IM"
        navigator.addSubview(title)

        if Config.LOGGING {
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openLogController(recognizer:)))
            tapGesture.numberOfTapsRequired = 1
            title.isUserInteractionEnabled =  true
            title.addGestureRecognizer(tapGesture)
        }

        menu.setTitle("⋮", for: .normal)
        menu.setTitleColor(.black, for: .normal)
        menu.titleLabel!.font = UIFont.boldSystemFont(ofSize: 24)
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.addTarget(self, action: #selector(open_menu(sender:)), for: .touchUpInside)
        navigator.addSubview(menu)

        connectionStatusIndicator.translatesAutoresizingMaskIntoConstraints = false
        connectionStatusIndicator.activityIndicatorViewStyle = .gray
        connectionStatusIndicator.hidesWhenStopped = true
        connectionStatusIndicator.stopAnimating()
        navigator.addSubview(connectionStatusIndicator)

        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: navigator.leftAnchor),
            title.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)
            ])
        NSLayoutConstraint.activate([
            menu.rightAnchor.constraint(equalTo: navigator.rightAnchor),
            menu.centerYAnchor.constraint(equalTo: navigator.centerYAnchor),
            menu.heightAnchor.constraint(equalTo: navigator.heightAnchor)
            ])
        NSLayoutConstraint.activate([
            connectionStatusIndicator.rightAnchor.constraint(equalTo: menu.leftAnchor),
            connectionStatusIndicator.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)
            ])

        navigator.autoresizingMask = .flexibleWidth
        self.navigationItem.titleView = navigator

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .leading
        layout.distribution = .fill

        adapter = ChannelListAdapter(service!, self)
        channelListView.translatesAutoresizingMaskIntoConstraints = false
        channelListView.register(ChannelCell.self, forCellReuseIdentifier: "channel")
        channelListView.dataSource = adapter
        channelListView.delegate = adapter
        channelListView.backgroundColor = UIColor.clear

        listArea.layer.backgroundColor = UIColor.white.withAlphaComponent(0.39).cgColor
        listArea.addSubview(channelListView)

        channelListView.widthAnchor.constraint(equalTo: listArea.widthAnchor).isActive = true
        channelListView.heightAnchor.constraint(equalTo: listArea.heightAnchor).isActive = true

        fab.translatesAutoresizingMaskIntoConstraints = false
        fab.setTitle("+", for: .normal)
        fab.titleLabel?.font = fab.titleLabel?.font.withSize(32)
        fab.contentEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0)
        fab.backgroundColor = UIColor(red: 0, green: 0.61465252229292133, blue: 1, alpha: 1)
        fab.layer.cornerRadius = 32
        fab.addTarget(self, action: #selector(new_channel(sender:)), for: .touchUpInside)

        listArea.addSubview(fab)
        listArea.bringSubview(toFront: fab)

        fab.widthAnchor.constraint(equalToConstant: 64).isActive = true
        fab.heightAnchor.constraint(equalToConstant: 64).isActive = true
        fab.bottomAnchor.constraint(equalTo: listArea.bottomAnchor, constant: -16).isActive = true
        fab.rightAnchor.constraint(equalTo: listArea.rightAnchor, constant: -16).isActive = true

        listArea.translatesAutoresizingMaskIntoConstraints = false
        layout.addArrangedSubview(listArea)

        listArea.widthAnchor.constraint(equalTo: layout.widthAnchor).isActive = true

        self.view.addSubview(layout)

        layout.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        layout.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        layout.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        layout.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true

        background.translatesAutoresizingMaskIntoConstraints = false
        background.contentMode = .scaleAspectFill
        background.image = UIImage(named: "background")
        self.view.addSubview(background)

        background.topAnchor.constraint(equalTo: listArea.topAnchor).isActive = true
        background.leftAnchor.constraint(equalTo: listArea.leftAnchor).isActive = true
        background.rightAnchor.constraint(equalTo: listArea.rightAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: listArea.bottomAnchor).isActive = true

        self.view.bringSubview(toFront: layout)

        let pendingBackground = UIView()
        pendingBackground.translatesAutoresizingMaskIntoConstraints = false
        pendingBackground.backgroundColor = UIColor(red: 0.6666666666666666, green: 0.7333333333333333, blue: 1, alpha: 1)
        pendingArea.insertSubview(pendingBackground, at: 0)

        layout.addArrangedSubview(pendingArea)
        pendingArea.widthAnchor.constraint(equalTo: layout.widthAnchor).isActive = true
        pendingArea.heightAnchor.constraint(equalToConstant: 64).isActive = true

        pendingBackground.topAnchor.constraint(equalTo: pendingArea.topAnchor).isActive = true
        pendingBackground.leftAnchor.constraint(equalTo: pendingArea.leftAnchor).isActive = true
        pendingBackground.rightAnchor.constraint(equalTo: pendingArea.rightAnchor).isActive = true
        pendingBackground.bottomAnchor.constraint(equalTo: pendingArea.bottomAnchor).isActive = true

        pendingPOILayout.translatesAutoresizingMaskIntoConstraints = false

        pendingArea.addSubview(pendingPOILayout)

        pendingPOILayout.centerXAnchor.constraint(equalTo: pendingArea.centerXAnchor).isActive = true
        pendingPOILayout.centerYAnchor.constraint(equalTo: pendingArea.centerYAnchor).isActive = true

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

        newChannelPointer.translatesAutoresizingMaskIntoConstraints = false
        newChannelPointer.image = UIImage(named: "pointer_bottom_right")
        self.view.addSubview(newChannelPointer)
        self.view.bringSubview(toFront: newChannelPointer)
        newChannelPointer.rightAnchor.constraint(equalTo: fab.leftAnchor).isActive = true
        newChannelPointer.bottomAnchor.constraint(equalTo: fab.topAnchor).isActive = true
        newChannelPointer.isHidden = true

        newChannelDesc.key = Key.TIP_NEW_CHANNEL
        newChannelDesc.callback = checkTips
        self.view.addSubview(newChannelDesc)
        self.view.bringSubview(toFront: newChannelDesc)
        newChannelDesc.bottomAnchor.constraint(equalTo: newChannelPointer.topAnchor).isActive = true
        newChannelDesc.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        newChannelDesc.isHidden = true

        enterChannelPointer.translatesAutoresizingMaskIntoConstraints = false
        enterChannelPointer.image = UIImage(named: "pointer_up")
        self.view.addSubview(enterChannelPointer)
        self.view.bringSubview(toFront: enterChannelPointer)
        enterChannelPointer.isHidden = true

        enterChannelDesc.key = Key.TIP_ENTER_CHANNEL
        enterChannelDesc.callback = checkTips
        self.view.addSubview(enterChannelDesc)
        self.view.bringSubview(toFront: enterChannelDesc)
        enterChannelDesc.topAnchor.constraint(equalTo: enterChannelPointer.bottomAnchor).isActive = true
        enterChannelDesc.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        enterChannelDesc.isHidden = true

        toggleChannelPointer.translatesAutoresizingMaskIntoConstraints = false
        toggleChannelPointer.image = UIImage(named: "pointer_up_right")
        self.view.addSubview(toggleChannelPointer)
        self.view.bringSubview(toFront: toggleChannelPointer)
        toggleChannelPointer.isHidden = true

        toggleChannelDesc.key = Key.TIP_TOGGLE_CHANNEL
        toggleChannelDesc.callback = checkTips
        self.view.addSubview(toggleChannelDesc)
        self.view.bringSubview(toFront: toggleChannelDesc)
        toggleChannelDesc.topAnchor.constraint(equalTo: toggleChannelPointer.bottomAnchor).isActive = true
        toggleChannelDesc.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        toggleChannelDesc.isHidden = true
    }

    func checkTips() {
        cover.isHidden = true
        newChannelPointer.isHidden = true
        newChannelDesc.isHidden = true
        toggleChannelPointer.isHidden = true
        toggleChannelDesc.isHidden = true
        enterChannelPointer.isHidden = true
        enterChannelDesc.isHidden = true

        if UserDefaults.standard.bool(forKey: Key.TIP_NEW_CHANNEL) != true {
            newChannelPointer.isHidden = false
            newChannelDesc.isHidden = false
            cover.isHidden = false
            return
        }

        let hasChannel = adapter!.tableView(channelListView, numberOfRowsInSection: 0) > ChannelListAdapter.PADDING_ROWS

        if hasChannel && UserDefaults.standard.bool(forKey: Key.TIP_TOGGLE_CHANNEL) != true {
            toggleChannelPointer.isHidden = false
            toggleChannelDesc.isHidden = false
            cover.isHidden = false
            return
        }

        if hasChannel && UserDefaults.standard.bool(forKey: Key.TIP_ENTER_CHANNEL) != true {
            enterChannelPointer.isHidden = false
            enterChannelDesc.isHidden = false
            cover.isHidden = false
            return
        }
    }

    func openLogController(recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "log", sender: nil)
    }

    func open_menu(sender: Any) {
        _ = DialogAppMenu(self, menu)
    }

    func new_channel(sender: UIButton) {
        _ = DialogNewChannel(self, sender)
    }

    override func viewDidAppear(_ animated: Bool) {
        if let sv = service {
            if sv.getClientId() == nil {
                let vc = storyboard?.instantiateViewController(withIdentifier: "login")
                self.present(vc!, animated: true)
                return
            }
        }
        checkTips()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let sv = service {
            if let poi = sv.pendingPOI {
                pendingPOILayout.isHidden = false
                pendingPOILayout.setPOI(poi: poi)
                pendingArea.isHidden = false
            } else {
                pendingArea.isHidden = true
            }

            sv.setViewController(self)
            channelListChangedCbkey = sv.addChannelListChangedListener(channelListChangedCbkey, self)
            connectionStatusChangedCbKey = sv.addConnectionStatusChangedListener(connectionStatusChangedCbKey, self)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let sv = service {
            sv.setViewController(nil)
            if channelListChangedCbkey != nil {
                sv.removeChannelListChangedListener(channelListChangedCbkey)
                channelListChangedCbkey = nil
            }
            if connectionStatusChangedCbKey != nil {
                sv.removeConnectionStatusChangedListener(connectionStatusChangedCbKey)
                connectionStatusChangedCbKey = nil
            }
        }
        super.viewWillDisappear(animated)
    }

    func channelListChanged() {
        self.adapter?.reload()
        self.channelListView.reloadData()
    }

    func onConnectionStatusChanged(_ connected: Bool) {
        if connected {
            connectionStatusIndicator.stopAnimating()
        } else {
            connectionStatusIndicator.startAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = channelListView.indexPathForSelectedRow {
            navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
            let channelController = segue.destination as! ChannelController
            channelController.channel = adapter!.getChannel(indexPath.row)
        }
    }
}
