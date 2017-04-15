//
//  EnchantmentController.swift
//  whereim
//
//  Created by Buganini Q on 22/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class EnchantmentCell: UITableViewCell {
    let title = UILabel()
    let loadingSwitch = UILoadingSwitch()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        title.adjustsFontSizeToFitWidth = false
        title.translatesAutoresizingMaskIntoConstraints = false

        loadingSwitch.requestLayout()
        loadingSwitch.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(title)
        self.contentView.addSubview(loadingSwitch)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:15),
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

class ChannelEnchantmentAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    var enchantmentList: EnchantmentList
    let vc: UIViewController
    let service: CoreService
    let channel: Channel
    let channelController: ChannelController
    let numberOfSections = 3

    init(_ viewController: UIViewController, _ service: CoreService, _ channel: Channel, _ channelController: ChannelController) {
        self.vc = viewController
        self.service = service
        self.channel = channel
        self.channelController = channelController
        self.enchantmentList = service.getChannelEnchantment(channel.id!)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return enchantmentList.public_list.count > 0 ? enchantmentList.public_list.count : 1
        case 2: return enchantmentList.private_list.count > 0 ? enchantmentList.private_list.count : 1
        default:
            return 0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "self".localized
        case 1: return "public_enchantment".localized
        case 2: return "private_enchantment".localized
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "enchantment", for: indexPath) as! EnchantmentCell
            cell.title.text = String(format: "radius_m".localized, channel.radius!)
            cell.loadingSwitch.setEnabled(channel.enable_radius)
            cell.loadingSwitch.uiswitch.tag = numberOfSections * indexPath.row + indexPath.section
            cell.loadingSwitch.uiswitch.addTarget(self, action: #selector(switchClicked(sender:)), for: UIControlEvents.touchUpInside)

            return cell
        } else {
            if let enchantment = getEnchantment(indexPath.section, indexPath.row) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "enchantment", for: indexPath) as! EnchantmentCell
                cell.title.text = enchantment.name
                cell.loadingSwitch.setEnabled(enchantment.enabled)
                cell.loadingSwitch.uiswitch.tag = numberOfSections * indexPath.row + indexPath.section
                cell.loadingSwitch.uiswitch.addTarget(self, action: #selector(switchClicked(sender:)), for: UIControlEvents.touchUpInside)

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "placeholder", for: indexPath) as! UIPlaceHolderCell
                cell.label.text = "object_create_hint".localized
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section != 0 {
            if let enchantment = getEnchantment(indexPath.section, indexPath.row) {
                channelController.moveTo(enchantment: enchantment)
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            if let _ = getEnchantment(indexPath.section, indexPath.row) {
                return true
            } else {
                return false
            }
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            let edit = UITableViewRowAction(style: .normal, title: "✏️", handler: {(action, indexPath) -> Void in
                tableView.setEditing(false, animated: true)
                _ = DialogEditRadius(self.vc, self.channel)
            })
            return [edit]
        } else {
            let edit = UITableViewRowAction(style: .normal, title: "✏️", handler: {(action, indexPath) -> Void in
                tableView.setEditing(false, animated: true)

                if let enchantment = self.getEnchantment(indexPath.section, indexPath.row) {
                    _ = DialogEditEnchantment(self.vc, enchantment)
                }
            })
            let delete = UITableViewRowAction(style: .destructive, title: "✖", handler: {(action, indexPath) -> Void in
                tableView.setEditing(false, animated: true)

                if let enchantment = self.getEnchantment(indexPath.section, indexPath.row) {
                    _ = DialogDeleteEnchantment(self.vc, enchantment)
                }
            })

            return [delete, edit]
        }
    }

    func switchClicked(sender: UISwitch) {
        let row = sender.tag / numberOfSections
        let section = sender.tag % numberOfSections
        if section == 0 {
            service.toggleRadiusEnabled(channel)
        } else {
            let enchantment = getEnchantment(section, row)!
            service.toggleEnchantmentEnabled(enchantment)
        }
    }

    func getEnchantment(_ section: Int, _ row: Int) -> Enchantment? {
        switch section {
        case 1:
            if row < enchantmentList.public_list.count {
                return enchantmentList.public_list[row]
            }
        case 2:
            if row < enchantmentList.private_list.count {
                return enchantmentList.private_list[row]
            }
        default:
            return nil
        }
        return nil
    }

    func reload() {
        self.enchantmentList = service.getChannelEnchantment(channel.id!)
    }
}

class EnchantmentController: UIViewController, Callback, ChannelChangedListener {
    var service: CoreService?
    var channel: Channel?
    var adapter: ChannelEnchantmentAdapter?
    var cbkey: Int?
    var channelCbkey: Int?

    @IBOutlet weak var enchantmentListView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let parent = self.tabBarController as! ChannelController
        channel = parent.channel
        
        service = CoreService.bind()
        adapter = ChannelEnchantmentAdapter(self, (service)!, channel!, parent)
        enchantmentListView.register(EnchantmentCell.self, forCellReuseIdentifier: "enchantment")
        enchantmentListView.register(UIPlaceHolderCell.self, forCellReuseIdentifier: "placeholder")
        enchantmentListView.dataSource = adapter
        enchantmentListView.delegate = adapter
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cbkey = service!.addEnchantmentListener(channel!, cbkey, self)
        channelCbkey = service!.addChannelChangedListener(channel!, cbkey, self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let sv = service {
            sv.removeEnchantmentListener(channel!, cbkey)
            sv.removeChannelChangedListener(channel!, channelCbkey)
        }

        super.viewWillDisappear(animated)
    }

    func onCallback() {
        adapter!.reload()
        enchantmentListView.reloadData()
    }

    func channelChanged() {
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
