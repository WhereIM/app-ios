//
//  ChannelListController.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelListAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    var channelList: [Channel]
    let service: CoreService

    init(_ service: CoreService) {
        self.service = service
        self.channelList = service.getChannelList()
    }

    func reload() {
        self.channelList = service.getChannelList()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channel", for: indexPath)


        cell.textLabel?.text = channelList[indexPath.row].channel_name

        return cell
    }

    func getChannel(_ index: Int) -> Channel {
        return channelList[index]
    }
}

class ChannelListController: UIViewController, ChannelListChangedListener {
    var service: CoreService?

    @IBOutlet weak var channelListView: UITableView!

    var adapter: ChannelListAdapter?
    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()
        adapter = ChannelListAdapter((service)!)
        channelListView.dataSource = adapter
        channelListView.delegate = adapter
    }

    var cbkey: Int?
    override func viewDidAppear(_ animated: Bool) {
        if service!.getClientId() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "login")
            self.present(vc!, animated: true)
            return
        }
        cbkey = service!.addChannelListChangedListener(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        service!.removeChannelListChangedListener(cbkey)
    }

    func channelListChanged() {
        DispatchQueue.main.async {
            self.adapter?.reload()
            self.channelListView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = channelListView.indexPathForSelectedRow {
            let channelController = segue.destination as! ChannelController
            channelController.channel = adapter!.getChannel(indexPath.row)
        }
    }
}
