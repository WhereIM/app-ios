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
    let title = UILabel()
    let subtitle = UILabel()
    let loadingSwitch = UILoadingSwitch()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

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

        self.contentView.addSubview(titleLayout)
        self.contentView.addSubview(loadingSwitch)

        NSLayoutConstraint.activate([
            titleLayout.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:15),
            titleLayout.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
        NSLayoutConstraint.activate([
            loadingSwitch.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant:-15),
            loadingSwitch.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChannelListAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    var channelList: [Channel]
    let service: CoreService
    let vc: UIViewController

    init(_ service: CoreService, _ viewcontroller: UIViewController) {
        self.service = service
        self.channelList = service.getChannelList()
        self.vc = viewcontroller
    }

    func reload() {
        self.channelList = service.getChannelList()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelList.count + 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channel", for: indexPath) as! ChannelCell

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
            cell.backgroundColor = UIColor(red:0.93, green:0.95, blue:0.98, alpha:1.0)
        } else {
            cell.backgroundColor = UIColor.clear
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
        let archive = UITableViewRowAction(style: .normal, title: nil, handler: {(action, indexPath) -> Void in
            tableView.setEditing(false, animated: true)

            self.service.toggleChannelEnabled(channel)
        })
        if channel.enabled == true {
            archive.title = "🔒"
        } else {
            archive.title = "🔓"
        }
        return [leave, archive, edit]
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

    let layout = UIStackView()
    let listArea = UIView()
    let pendingArea = UIView()
    let channelListView = UITableView()
    let fab = UIButton()
    let pendingPOILayout = PendingPoiViewHolder()


    let connectionStatusIndicator = UIActivityIndicatorView()
    var adapter: ChannelListAdapter?
    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()

        let navigator = UIView(frame: (self.navigationController?.navigationBar.bounds)!)

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

        listArea.addSubview(channelListView)

        channelListView.widthAnchor.constraint(equalTo: listArea.widthAnchor).isActive = true
        channelListView.heightAnchor.constraint(equalTo: listArea.heightAnchor).isActive = true

        fab.translatesAutoresizingMaskIntoConstraints = false
        fab.setTitle("+", for: .normal)
        fab.titleLabel?.font = fab.titleLabel?.font.withSize(32)
        fab.titleLabel?.baselineAdjustment = .alignCenters
        fab.backgroundColor = UIColor(red: 0, green: 0.61465252229292133, blue: 1, alpha: 1)
        fab.layer.cornerRadius = 32
        fab.addTarget(self, action: #selector(create_channel(sender:)), for: .touchUpInside)

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

        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = UIColor(red: 0.6666666666666666, green: 0.7333333333333333, blue: 1, alpha: 1)
        pendingArea.insertSubview(background, at: 0)

        layout.addArrangedSubview(pendingArea)
        pendingArea.widthAnchor.constraint(equalTo: layout.widthAnchor).isActive = true
        pendingArea.heightAnchor.constraint(equalToConstant: 64).isActive = true

        background.topAnchor.constraint(equalTo: pendingArea.topAnchor).isActive = true
        background.leftAnchor.constraint(equalTo: pendingArea.leftAnchor).isActive = true
        background.rightAnchor.constraint(equalTo: pendingArea.rightAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: pendingArea.bottomAnchor).isActive = true

        pendingPOILayout.translatesAutoresizingMaskIntoConstraints = false

        pendingArea.addSubview(pendingPOILayout)

        pendingPOILayout.centerXAnchor.constraint(equalTo: pendingArea.centerXAnchor).isActive = true
        pendingPOILayout.centerYAnchor.constraint(equalTo: pendingArea.centerYAnchor).isActive = true
    }

    func openLogController(recognizer: UITapGestureRecognizer) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "log")
        self.show(vc, sender: self)
    }

    func open_menu(sender: Any) {
        _ = DialogAppMenu(self, menu)
    }

    func create_channel(sender: UIButton) {
        _ = DialogCreateChannel(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        if let sv = service {
            if sv.getClientId() == nil {
                let vc = storyboard?.instantiateViewController(withIdentifier: "login")
                self.present(vc!, animated: true)
                return
            }
        }
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
