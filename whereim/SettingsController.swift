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

class TextSettingCell: UITableViewCell {
    let title = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none

        title.adjustsFontSizeToFitWidth = false
        title.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(title)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:15),
            title.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    let SETTING_POWER_SAVING = 0
    let tableView: UITableView
    let vc: UIViewController

    init(_ vc: UIViewController, _ tableView: UITableView) {
        self.vc = vc
        self.tableView = tableView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // general
            return 1
        case 1: // map provider
            return 2
        case 2: // search provider
            return 3
        case 3: // misc
            return 2
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "settings".localized
        case 1: return "map_service_provider".localized
        case 2: return "search_service_provider".localized
        case 3: return "misc".localized
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
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectable", for: indexPath) as! SelectableSettingCell
            switch indexPath.row {
            case 0:
                cell.title.text = "Google"
                cell.checked.isHidden = !(Config.getSearchProvider()==SearchProvider.GOOGLE)
            case 1:
                cell.title.text = "Mapbox"
                cell.checked.isHidden = !(Config.getSearchProvider()==SearchProvider.MAPBOX)
            case 2:
                cell.title.text = "Mapzen"
                cell.checked.isHidden = !(Config.getSearchProvider()==SearchProvider.MAPZEN)
            default:
                break
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextSettingCell
            switch indexPath.row {
            case 0:
                cell.title.text = "reset_tips".localized
                var resettable = false
                resettable = resettable || UserDefaults.standard.bool(forKey: Key.TIP_ENTER_CHANNEL) == true
                resettable = resettable || UserDefaults.standard.bool(forKey: Key.TIP_INVITE) == true
                resettable = resettable || UserDefaults.standard.bool(forKey: Key.TIP_NEW_CHANNEL) == true
                resettable = resettable || UserDefaults.standard.bool(forKey: Key.TIP_TOGGLE_CHANNEL) == true
                resettable = resettable || UserDefaults.standard.bool(forKey: Key.TIP_TOGGLE_CHANNEL_2) == true
                cell.title.textColor = resettable ? UIColor.black : UIColor.lightGray
            case 1:
                cell.title.text = "about".localized
            default:
                break
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1: // map provider
            switch indexPath.row {
            case 0:
                Config.setMapProvider(.GOOGLE)
                tableView.reloadData()
            case 1:
                Config.setMapProvider(.MAPBOX)
                Config.setSearchProvider(.MAPZEN)
                tableView.reloadData()
            default:
                break
            }
        case 2: // search provider
            switch indexPath.row {
            case 0:
                Config.setSearchProvider(.GOOGLE)
                Config.setMapProvider(.GOOGLE)
                tableView.reloadData()
            case 1:
                Config.setSearchProvider(.MAPBOX)
                tableView.reloadData()
            case 2:
                Config.setSearchProvider(.MAPZEN)
                tableView.reloadData()
            default:
                break
            }
        case 3:
            switch indexPath.row {
            case 0:
                UserDefaults.standard.removeObject(forKey: Key.TIP_ENTER_CHANNEL)
                UserDefaults.standard.removeObject(forKey: Key.TIP_INVITE)
                UserDefaults.standard.removeObject(forKey: Key.TIP_NEW_CHANNEL)
                UserDefaults.standard.removeObject(forKey: Key.TIP_TOGGLE_CHANNEL)
                UserDefaults.standard.removeObject(forKey: Key.TIP_TOGGLE_CHANNEL_2)
                tableView.reloadData()
            case 1:
                vc.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "about".localized, style: .plain, target: nil, action: nil)
                vc.performSegue(withIdentifier: "about", sender: nil)
            default:
                break
            }
        default:
            break
        }
    }

    @objc func switchClicked(sender: UISwitch) {
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

        adapter = SettingsAdapter(self, settings)
        settings.register(SelectableSettingCell.self, forCellReuseIdentifier: "selectable")
        settings.register(SwitchSettingCell.self, forCellReuseIdentifier: "switch")
        settings.register(TextSettingCell.self, forCellReuseIdentifier: "text")
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
