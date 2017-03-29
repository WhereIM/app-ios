//
//  MarkerController.swift
//  whereim
//
//  Created by Buganini Q on 22/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class MarkerCell: UITableViewCell {
    let icon = UIImageView()
    let title = UILabel()
    let loadingSwitch = UILoadingSwitch()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.frame = CGRect(x: 0, y: 0, width: 43, height: 43)

        title.adjustsFontSizeToFitWidth = false
        title.translatesAutoresizingMaskIntoConstraints = false

        loadingSwitch.requestLayout()
        loadingSwitch.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(icon)
        self.contentView.addSubview(title)
        self.contentView.addSubview(loadingSwitch)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.icon.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
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

class ChannelMarkerAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    var markerList: MarkerList
    let service: CoreService
    let channel: Channel
    let channelController: ChannelController
    let numberOfSections = 2

    init(_ service: CoreService, _ channel: Channel, _ channelController: ChannelController) {
        self.service = service
        self.channel = channel
        self.channelController = channelController
        self.markerList = service.getChannelMarker(channel.id!)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return markerList.public_list.count
        case 1: return markerList.private_list.count
        default:
            return 0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "is_public".localized
        case 1: return "is_private".localized
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "marker", for: indexPath) as! MarkerCell

        let marker = getMarker(indexPath.section, indexPath.row)!

        cell.icon.image = marker.getIcon()
        cell.title.text = marker.name
        cell.loadingSwitch.setEnabled(marker.enable)
        cell.loadingSwitch.uiswitch.tag = numberOfSections * indexPath.row + indexPath.section
        cell.loadingSwitch.uiswitch.addTarget(self, action: #selector(switchClicked(sender:)), for: UIControlEvents.touchUpInside)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let marker = getMarker(indexPath.section, indexPath.row)!
        channelController.moveTo(marker: marker)
    }

    func switchClicked(sender: UISwitch) {
        let row = sender.tag / numberOfSections
        let section = sender.tag % numberOfSections
        let marker = getMarker(section, row)!
        service.toggleMarkerEnabled(marker)
    }

    func getMarker(_ section: Int, _ row: Int) -> Marker? {
        switch section {
        case 0: return markerList.public_list[row]
        case 1: return markerList.private_list[row]
        default:
            return nil
        }
    }

    func reload() {
        self.markerList = service.getChannelMarker(channel.id!)
    }
}

class MarkerController: UIViewController, Callback {
    var service: CoreService?
    var channel: Channel?
    var adapter: ChannelMarkerAdapter?
    var cbkey: Int?

    @IBOutlet weak var markerListView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let parent = self.tabBarController as! ChannelController
        channel = parent.channel

        service = CoreService.bind()
        adapter = ChannelMarkerAdapter((service)!, channel!, parent)
        markerListView.register(MarkerCell.self, forCellReuseIdentifier: "marker")
        markerListView.dataSource = adapter
        markerListView.delegate = adapter
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cbkey = service!.addMarkerListener(channel!, cbkey, self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let sv = service {
            sv.removeMarkerListener(channel!, cbkey)
        }

        super.viewWillDisappear(animated)
    }

    func onCallback() {
        adapter!.reload()
        markerListView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
