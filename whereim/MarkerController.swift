//
//  MarkerController.swift
//  whereim
//
//  Created by Buganini Q on 22/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelMarkerAdapter: NSObject, UITableViewDataSource, UITableViewDelegate, Callback {
    var MarkerList: MarkerList
    let service: CoreService
    let channel: Channel

    init(_ service: CoreService, _ channel: Channel) {
        self.service = service
        self.channel = channel
        self.MarkerList = service.getChannelMarker(channel.id!)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return MarkerList.public_list.count
        case 1: return MarkerList.private_list.count
        default:
            return 0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "marker", for: indexPath)

        let Marker = getMarker(indexPath)!

        cell.textLabel?.text = Marker.name

        return cell
    }

    func getMarker(_ index: IndexPath) -> Marker? {
        switch index.section {
        case 0: return MarkerList.public_list[index.row]
        case 1: return MarkerList.private_list[index.row]
        default:
            return nil
        }
    }

    func onCallback() {
        self.MarkerList = service.getChannelMarker(channel.id!)
    }
}

class MarkerController: UIViewController {
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
        markerListView.dataSource = adapter
        markerListView.delegate = adapter
    }

    override func viewDidAppear(_ animated: Bool) {
        cbkey = service!.addMarkerListener(channel!, adapter!)
    }

    deinit {
        if let sv = service {
            sv.removeMarkerListener(channel!, cbkey)
        }
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
