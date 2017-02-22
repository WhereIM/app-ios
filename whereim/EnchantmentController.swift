//
//  EnchantmentController.swift
//  whereim
//
//  Created by Buganini Q on 22/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelEnchantmentAdapter: NSObject, UITableViewDataSource, UITableViewDelegate, Callback {
    var enchantmentList: EnchantmentList
    let service: CoreService
    let channel: Channel

    init(_ service: CoreService, _ channel: Channel) {
        self.service = service
        self.channel = channel
        self.enchantmentList = service.getChannelEnchantment(channel.id!)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return enchantmentList.public_list.count
        case 1: return enchantmentList.private_list.count
        default:
            return 0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("public", comment: "Public Enchantment")
        case 1: return NSLocalizedString("private", comment: "Private Enchantment")
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "enchantment", for: indexPath)

        let enchantment = getEnchantment(indexPath)!

        cell.textLabel?.text = enchantment.name

        return cell
    }

    func getEnchantment(_ index: IndexPath) -> Enchantment? {
        switch index.section {
        case 0: return enchantmentList.public_list[index.row]
        case 1: return enchantmentList.private_list[index.row]
        default:
            return nil
        }
    }

    func onCallback() {
        self.enchantmentList = service.getChannelEnchantment(channel.id!)
    }
}

class EnchantmentController: UIViewController {
    var service: CoreService?
    var channel: Channel?
    var adapter: ChannelEnchantmentAdapter?
    var cbkey: Int?

    @IBOutlet weak var enchantmentListView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let parent = self.tabBarController as! ChannelController
        channel = parent.channel
        
        service = CoreService.bind()
        adapter = ChannelEnchantmentAdapter((service)!, channel!)
        enchantmentListView.dataSource = adapter
        enchantmentListView.delegate = adapter
    }

    override func viewDidAppear(_ animated: Bool) {
        cbkey = service!.addEnchantmentListener(channel!, adapter!)
    }

    deinit {
        if let sv = service {
            sv.removeEnchantmentListener(channel!, cbkey)
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
