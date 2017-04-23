//
//  SettingsController.swift
//  whereim
//
//  Created by Buganini Q on 23/04/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class SwitchSettingCell: UITableViewCell {
    let title = UILabel()
    let toggle = UISwitch()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        title.adjustsFontSizeToFitWidth = false
        title.translatesAutoresizingMaskIntoConstraints = false

        toggle.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(title)
        self.contentView.addSubview(toggle)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:15),
            title.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
        NSLayoutConstraint.activate([
            toggle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant:-15),
            toggle.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    let SETTING_POWER_SAVING = 0

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let service = CoreService.bind()
                let cell = tableView.dequeueReusableCell(withIdentifier: "switch", for: indexPath) as! SwitchSettingCell
                cell.title.text = "power_saving".localized
                cell.toggle.setOn(service.getPowerSaving(), animated: false)
                cell.toggle.tag = SETTING_POWER_SAVING
                cell.toggle.addTarget(self, action: #selector(switchClicked(sender:)), for: UIControlEvents.touchUpInside)
                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }

    func switchClicked(sender: UISwitch) {
        switch sender.tag {
        case SETTING_POWER_SAVING:
            let service = CoreService.bind()
            service.setPowerSaving(enabled: sender.isOn)
            return
        default:
            return
        }
    }
}

class SettingsController: UIViewController {
    var adapter: SettingsAdapter?

    @IBOutlet weak var settings: UITableView!

    override func viewDidLoad() {

        adapter = SettingsAdapter()
        settings.register(SwitchSettingCell.self, forCellReuseIdentifier: "switch")
        settings.estimatedRowHeight = 70
        settings.rowHeight = UITableViewAutomaticDimension
        settings.allowsSelection = false
        settings.dataSource = adapter
        settings.delegate = adapter

        super.viewDidLoad()
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
