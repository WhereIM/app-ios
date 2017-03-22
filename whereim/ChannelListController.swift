//
//  ChannelListController.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelCell: UITableViewCell {
    let titleLayout = UICompactStackView()
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

        loadingSwitch.requestLayout()
        titleLayout.requestLayout()

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
        return channelList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channel", for: indexPath) as! ChannelCell

        if channelList[indexPath.row].user_channel_name != nil && !channelList[indexPath.row].user_channel_name!.isEmpty {
            cell.title.text = channelList[indexPath.row].user_channel_name
            cell.subtitle.text = channelList[indexPath.row].channel_name
            cell.subtitle.isHidden = false
        } else {
            cell.title.text = channelList[indexPath.row].channel_name
            cell.subtitle.text = nil
            cell.subtitle.isHidden = true
        }

        cell.loadingSwitch.uiswitch.tag = indexPath.row
        cell.loadingSwitch.uiswitch.addTarget(self, action: #selector(switchClicked(sender:)), for: UIControlEvents.touchUpInside)
        cell.loadingSwitch.setEnabled(channelList[indexPath.row].enable)
        cell.titleLayout.requestLayout()

        return cell
    }

    func switchClicked(sender: UISwitch) {
        let channel = channelList[sender.tag]
        service.toggleChannelEnabled(channel)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.vc.performSegue(withIdentifier: "enter_channel", sender: self)
    }

    func getChannel(_ index: Int) -> Channel {
        return channelList[index]
    }
}

class ChannelListController: UIViewController, ChannelListChangedListener, ConnectionStatusCallback {
    var service: CoreService?
    var channelListChangedCbkey: Int?
    var connectionStatusChangedCbKey: Int?

    @IBOutlet weak var channelListView: UITableView!
    @IBOutlet weak var fab: UIButton!

    let connectionStatusIndicator = UIActivityIndicatorView()
    var adapter: ChannelListAdapter?
    override func viewDidLoad() {
        super.viewDidLoad()

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

        connectionStatusIndicator.translatesAutoresizingMaskIntoConstraints = false
        connectionStatusIndicator.activityIndicatorViewStyle = .gray
        connectionStatusIndicator.startAnimating()
        navigator.addSubview(connectionStatusIndicator)

        NSLayoutConstraint.activate([title.leftAnchor.constraint(equalTo: navigator.leftAnchor), title.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)])
        NSLayoutConstraint.activate([connectionStatusIndicator.rightAnchor.constraint(equalTo: navigator.rightAnchor), connectionStatusIndicator.centerYAnchor.constraint(equalTo: navigator.centerYAnchor)])

        navigator.autoresizingMask = .flexibleWidth
        self.navigationItem.titleView = navigator

        service = CoreService.bind()
        adapter = ChannelListAdapter((service)!, self)
        channelListView.register(ChannelCell.self, forCellReuseIdentifier: "channel")
        channelListView.dataSource = adapter
        channelListView.delegate = adapter

        fab.titleLabel?.baselineAdjustment = .alignCenters
        fab.layer.cornerRadius = 32
        fab.addTarget(self, action: #selector(create_channel(sender:)), for: .touchUpInside)
    }

    func openLogController(recognizer: UITapGestureRecognizer) {
        print(openLogController)
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "log")
        self.show(vc, sender: self)
    }

    func create_channel(sender: UIButton) {
        _ = DialogCreateChannel(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        if service!.getClientId() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "login")
            self.present(vc!, animated: true)
            return
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        channelListChangedCbkey = service!.addChannelListChangedListener(channelListChangedCbkey, self)
        connectionStatusChangedCbKey = service!.addConnectionStatusChangedListener(connectionStatusChangedCbKey, self)
    }

    override func viewWillDisappear(_ animated: Bool) {
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

        super.viewWillDisappear(animated)
    }

    func channelListChanged() {
        self.adapter?.reload()
        self.channelListView.reloadData()
    }

    func onConnectionStatusChanged(_ connected: Bool) {
        connectionStatusIndicator.isHidden = connected
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
