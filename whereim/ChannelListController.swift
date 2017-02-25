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

        if channelList[indexPath.row].user_channel_name != nil {
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

class ChannelListController: UIViewController, ChannelListChangedListener {
    var service: CoreService?
    var cbkey: Int?

    @IBOutlet weak var channelListView: UITableView!

    var adapter: ChannelListAdapter?
    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()
        adapter = ChannelListAdapter((service)!, self)
        channelListView.register(ChannelCell.self, forCellReuseIdentifier: "channel")
        channelListView.dataSource = adapter
        channelListView.delegate = adapter
    }

    override func viewDidAppear(_ animated: Bool) {
        if service!.getClientId() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "login")
            self.present(vc!, animated: true)
            return
        }
        cbkey = service!.addChannelListChangedListener(cbkey, self)
    }

    deinit {
        if let sv = service {
            sv.removeChannelListChangedListener(cbkey)
        }
    }

    func channelListChanged() {
        self.adapter?.reload()
        self.channelListView.reloadData()
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
