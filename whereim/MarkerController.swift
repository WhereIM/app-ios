//
//  MarkerController.swift
//  whereim
//
//  Created by Buganini Q on 22/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelMarkerAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    var markerList: MarkerList
    let service: CoreService
    let channel: Channel
    let numberOfSections = 2

    init(_ service: CoreService, _ channel: Channel) {
        self.service = service
        self.channel = channel
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
        case 0: return NSLocalizedString("public", comment: "Public Marker")
        case 1: return NSLocalizedString("private", comment: "Private Marker")
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "marker", for: indexPath) as! UITableViewCellWIthTextLoadingSwitch

        let marker = getMarker(indexPath.section, indexPath.row)!

        cell.title.text = marker.name
        cell.loadingSwitch.setEnabled(marker.enable)
        cell.loadingSwitch.uiswitch.tag = numberOfSections * indexPath.row + indexPath.section
        cell.loadingSwitch.uiswitch.addTarget(self, action: #selector(switchClicked(sender:)), for: UIControlEvents.touchUpInside)

        return cell
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
        adapter = ChannelMarkerAdapter((service)!, channel!)
        markerListView.allowsSelection = false
        markerListView.register(UITableViewCellWIthTextLoadingSwitch.self, forCellReuseIdentifier: "marker")
        markerListView.dataSource = adapter
        markerListView.delegate = adapter
    }

    override func viewDidAppear(_ animated: Bool) {
        cbkey = service!.addMarkerListener(channel!, cbkey, self)
    }

    deinit {
        if let sv = service {
            sv.removeMarkerListener(channel!, cbkey)
        }
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
