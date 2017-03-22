//
//  EnchantmentController.swift
//  whereim
//
//  Created by Buganini Q on 22/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelEnchantmentAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    var enchantmentList: EnchantmentList
    let service: CoreService
    let channel: Channel
    let numberOfSections = 2

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "enchantment", for: indexPath) as! UITableViewCellWIthTextLoadingSwitch

        let enchantment = getEnchantment(indexPath.section, indexPath.row)!

        cell.title.text = enchantment.name
        cell.loadingSwitch.setEnabled(enchantment.enable)
        cell.loadingSwitch.uiswitch.tag = numberOfSections * indexPath.row + indexPath.section
        cell.loadingSwitch.uiswitch.addTarget(self, action: #selector(switchClicked(sender:)), for: UIControlEvents.touchUpInside)

        return cell
    }

    func switchClicked(sender: UISwitch) {
        let row = sender.tag / numberOfSections
        let section = sender.tag % numberOfSections
        let enchantment = getEnchantment(section, row)!
        service.toggleEnchantmentEnabled(enchantment)
    }

    func getEnchantment(_ section: Int, _ row: Int) -> Enchantment? {
        switch section {
        case 0: return enchantmentList.public_list[row]
        case 1: return enchantmentList.private_list[row]
        default:
            return nil
        }
    }

    func reload() {
        self.enchantmentList = service.getChannelEnchantment(channel.id!)
    }
}

class EnchantmentController: UIViewController, Callback {
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
        enchantmentListView.allowsSelection = false
        enchantmentListView.register(UITableViewCellWIthTextLoadingSwitch.self, forCellReuseIdentifier: "enchantment")
        enchantmentListView.dataSource = adapter
        enchantmentListView.delegate = adapter
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cbkey = service!.addEnchantmentListener(channel!, cbkey, self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let sv = service {
            sv.removeEnchantmentListener(channel!, cbkey)
        }

        super.viewWillDisappear(animated)
    }

    func onCallback() {
        adapter!.reload()
        enchantmentListView.reloadData()
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
