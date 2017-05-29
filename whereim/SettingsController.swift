//
//  SettingsController.swift
//  whereim
//
//  Created by Buganini Q on 23/04/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class SelectableSettingCell: UITableViewCell {
    let checked = UILabel()
    let title = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none

        checked.adjustsFontSizeToFitWidth = false
        checked.translatesAutoresizingMaskIntoConstraints = false
        checked.text = "✔"

        title.adjustsFontSizeToFitWidth = false
        title.translatesAutoresizingMaskIntoConstraints = false


        self.contentView.addSubview(checked)
        self.contentView.addSubview(title)

        checked.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:15).isActive = true
        checked.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        title.leadingAnchor.constraint(equalTo: checked.trailingAnchor, constant:15).isActive = true
        title.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SwitchSettingCell: UITableViewCell {
    let title = UILabel()
    let toggle = UISwitch()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none

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
    let tableView: UITableView

    init(_ tableView: UITableView) {
        self.tableView = tableView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // general
            return 1
        case 1: // map provider
            return 2
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "settings".localized
        case 1: return "service_provider".localized
        default:
            return nil
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
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectable", for: indexPath) as! SelectableSettingCell
            switch indexPath.row {
            case 0:
                cell.title.text = "Google"
                cell.checked.isHidden = !(Config.getMapProvider()==MapProvider.GOOGLE)
            case 1:
                cell.title.text = "Mapbox"
                cell.checked.isHidden = !(Config.getMapProvider()==MapProvider.MAPBOX)
            default:
                break
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 { // map provider
            switch indexPath.row {
            case 0:
                Config.setMapProvider(.GOOGLE)
                tableView.reloadData()
            case 1:
                Config.setMapProvider(.MAPBOX)
                tableView.reloadData()
            default:
                break
            }
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

        adapter = SettingsAdapter(settings)
        settings.register(SelectableSettingCell.self, forCellReuseIdentifier: "selectable")
        settings.register(SwitchSettingCell.self, forCellReuseIdentifier: "switch")
        settings.estimatedRowHeight = 70
        settings.rowHeight = UITableViewAutomaticDimension
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
