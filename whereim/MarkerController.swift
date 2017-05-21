//
//  MarkerController.swift
//  whereim
//
//  Created by Buganini Q on 22/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit


class MateCell: UITableViewCell {
    let indicator = UILabel()
    let titleLayout = UIStackView()
    let title = UILabel()
    let subtitle = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.adjustsFontSizeToFitWidth = false
        indicator.text = "•"

        self.contentView.addSubview(indicator)
        indicator.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:15).isActive = true
        indicator.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true

        titleLayout.axis = .vertical
        titleLayout.alignment = .leading
        titleLayout.distribution = .fill

        title.adjustsFontSizeToFitWidth = false
        titleLayout.addArrangedSubview(title)

        subtitle.font = subtitle.font.withSize(12)
        subtitle.adjustsFontSizeToFitWidth = false
        titleLayout.addArrangedSubview(subtitle)

        titleLayout.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(titleLayout)

        titleLayout.leadingAnchor.constraint(equalTo: indicator.trailingAnchor, constant:15).isActive = true
        titleLayout.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
    var selfMate: Mate?
    var mateList: [Mate]
    var markerList: MarkerList
    let vc: MarkerController
    let service: CoreService
    let channel: Channel
    let channelController: ChannelController
    let numberOfSections = 4

    init(_ viewController: MarkerController, _ service: CoreService, _ channel: Channel, _ channelController: ChannelController) {
        self.vc = viewController
        self.service = service
        self.channel = channel
        self.channelController = channelController
        self.mateList = [Mate]()
        self.markerList = MarkerList()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if selfMate != nil {
                return 1
            }
            return 0
        case 1: return mateList.count > 0 ? mateList.count : 1
        case 2: return markerList.public_list.count > 0 ? markerList.public_list.count : 1
        case 3: return markerList.private_list.count > 0 ? markerList.private_list.count : 1
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
        case 1: return "mate".localized
        case 2: return "public_marker".localized
        case 3: return "private_marker".localized
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 || indexPath.section == 1 {
            if let mate = getMate(indexPath.section, indexPath.row) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "mate", for: indexPath) as! MateCell

                if mate.user_mate_name != nil && !mate.user_mate_name!.isEmpty {
                    cell.title.text = mate.user_mate_name
                    cell.subtitle.text = mate.mate_name
                    cell.subtitle.isHidden = false
                } else {
                    cell.title.text = mate.mate_name
                    cell.subtitle.text = nil
                    cell.subtitle.isHidden = true
                }

                if mate.latitude == nil || mate.longitude == nil {
                    cell.indicator.textColor = UIColor.gray
                } else if mate.stale {
                    cell.indicator.textColor = UIColor.orange
                } else {
                    cell.indicator.textColor = UIColor.green
                }

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "placeholder", for: indexPath) as! UIPlaceHolderCell

                if vc.filterKeyword == nil {
                    cell.label.text = "mate_invite_hint".localized
                } else {
                    cell.label.text = "no_match".localized
                }

                return cell
            }
        } else {
            if let marker = getMarker(indexPath.section, indexPath.row) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "marker", for: indexPath) as! MarkerCell
                cell.icon.image = marker.getIcon()
                cell.title.text = marker.name
                cell.loadingSwitch.setEnabled(marker.enabled)
                cell.loadingSwitch.uiswitch.tag = numberOfSections * indexPath.row + indexPath.section
                cell.loadingSwitch.uiswitch.addTarget(self, action: #selector(switchClicked(sender:)), for: UIControlEvents.touchUpInside)

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "placeholder", for: indexPath) as! UIPlaceHolderCell

                if vc.filterKeyword == nil {
                    cell.label.text = "object_create_hint".localized
                } else {
                    cell.label.text = "no_match".localized
                }

                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 || indexPath.section == 1 {
            if let mate = getMate(indexPath.section, indexPath.row) {
                channelController.moveTo(mate: mate)
            }
        } else {
            if let marker = getMarker(indexPath.section, indexPath.row) {
                channelController.moveTo(marker: marker)
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 || indexPath.section == 1 {
            if let _ = self.getMate(indexPath.section, indexPath.row) {
                return true
            }
        } else {
            if let _ = self.getMarker(indexPath.section, indexPath.row) {
                return true
            }
        }
        return false
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            let edit = UITableViewRowAction(style: .normal, title: "✏️", handler: {(action, indexPath) -> Void in
                tableView.setEditing(false, animated: true)

                if let mate = self.getMate(indexPath.section, indexPath.row) {
                    _ = DialogEditSelf(self.vc, mate)
                }
            })
            return [edit]
        } else if indexPath.section == 1 {
            let edit = UITableViewRowAction(style: .normal, title: "✏️", handler: {(action, indexPath) -> Void in
                tableView.setEditing(false, animated: true)

                if let mate = self.getMate(indexPath.section, indexPath.row) {
                    _ = DialogEditMate(self.vc, mate)
                }
            })
            return [edit]
        } else {
            let edit = UITableViewRowAction(style: .normal, title: "✏️", handler: {(action, indexPath) -> Void in
                tableView.setEditing(false, animated: true)

                if let marker = self.getMarker(indexPath.section, indexPath.row) {
                    _ = DialogEditMarker(self.vc, marker)
                }
            })
            let delete = UITableViewRowAction(style: .destructive, title: "✖", handler: {(action, indexPath) -> Void in
                tableView.setEditing(false, animated: true)

                if let marker = self.getMarker(indexPath.section, indexPath.row) {
                    _ = DialogDeleteMarker(self.vc, marker)
                }
            })

            return [delete,edit]
        }
    }

    func switchClicked(sender: UISwitch) {
        let row = sender.tag / numberOfSections
        let section = sender.tag % numberOfSections
        if let marker = getMarker(section, row) {
            service.toggleMarkerEnabled(marker)
        }
    }

    func getMate(_ section: Int, _ row: Int) -> Mate? {
        if section == 0 {
            return selfMate
        }
        if row < mateList.count {
            return mateList[row]
        }
        return nil
    }

    func getMarker(_ section: Int, _ row: Int) -> Marker? {
        switch section {
        case 2:
            if row < markerList.public_list.count {
                return markerList.public_list[row]
            }
        case 3:
            if row < markerList.private_list.count {
                return markerList.private_list[row]
            }
        default:
            return nil
        }
        return nil
    }

    func reload() {
        self.markerList = service.getChannelMarker(channel.id!, vc.filterKeyword)
        self.mateList = [Mate]()
        for mate in service.getChannelMate(channel.id!, filter: vc.filterKeyword) {
            if mate.id! == channel.mate_id! {
                self.selfMate = mate
            } else {
                self.mateList.append(mate)
            }
        }
    }
}

class MarkerController: UIViewController, Callback, FilterBarDelegate {
    var service: CoreService?
    var channel: Channel?
    var adapter: ChannelMarkerAdapter?
    var cbMatekey: Int?
    var cbMarkerkey: Int?
    var filterKeyword: String?
    let filterBar = FilterBar()
    let markerListView = UITableView()

    override func viewDidLoad() {
        let parent = self.tabBarController as! ChannelController
        channel = parent.channel
        service = CoreService.bind()

        filterBar.delegate = self
        filterBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(filterBar)
        filterBar.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        filterBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        filterBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

        markerListView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(markerListView)
        markerListView.topAnchor.constraint(equalTo: filterBar.bottomAnchor).isActive = true
        markerListView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        markerListView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        markerListView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true

        adapter = ChannelMarkerAdapter(self, (service)!, channel!, parent)
        markerListView.register(MateCell.self, forCellReuseIdentifier: "mate")
        markerListView.register(MarkerCell.self, forCellReuseIdentifier: "marker")
        markerListView.register(UIPlaceHolderCell.self, forCellReuseIdentifier: "placeholder")
        markerListView.dataSource = adapter
        markerListView.delegate = adapter

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        super.viewDidLoad()
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        adapter!.reload()
        markerListView.reloadData()
        cbMatekey = service!.addMateListener(channel!, cbMatekey, self)
        cbMarkerkey = service!.addMarkerListener(channel!, cbMarkerkey, self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let sv = service {
            sv.removeMateListener(channel!, cbMatekey)
            sv.removeMarkerListener(channel!, cbMarkerkey)
        }

        super.viewWillDisappear(animated)
    }

    func onFilter(keyword: String?) {
        filterKeyword = keyword
        onCallback()
    }

    func onCallback() {
        adapter!.reload()
        markerListView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func keyboardShown(_ n:NSNotification) {
        let d = n.userInfo!
        var r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        r = self.markerListView.convert(r, from:nil)
        self.markerListView.contentInset.bottom = r.size.height
        self.markerListView.scrollIndicatorInsets.bottom = r.size.height
    }

    func keyboardHide(_ n:NSNotification) {
        self.markerListView.contentInset.bottom = 0
        self.markerListView.scrollIndicatorInsets.bottom = 0
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
