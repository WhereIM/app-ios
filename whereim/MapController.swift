//
//  MapController.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import UIKit

protocol MapControllerInterface {
    init(_ mapController: MapController)
    func viewDidLoad(_ viewContrller: UIViewController)
    func viewWillAppear(_ viewContrller: UIViewController)
    func viewWillDisappear(_ viewContrller: UIViewController)
    func didReceiveMemoryWarning()
    func channelChanged()
    func getMapCenter() -> CLLocationCoordinate2D
    func updateSearchResults()
    func moveToSearchResult(at: Int)
    func moveTo(mate: Mate)
    func moveTo(marker: Marker?)
    func moveTo(enchantment: Enchantment?)
    func refreshEditing()
}

class MapController: UIViewController, ChannelChangedListener {
    var service: CoreService?
    var channel: Channel?
    var cbkey: Int?
    var channelCbkey: Int?
    var mapControllerImpl: MapControllerInterface?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        _init()
    }

    func _init() {
        mapControllerImpl = GoogleMapController(self)
    }

    let enchantmentPanel = UICompactStackView()
    let markerPanel = UICompactStackView()
    override func viewDidLoad() {
        service = CoreService.bind()
        let parent = self.tabBarController as! ChannelController
        channel = parent.channel
        parent.setMapCtrl(self)

        mapControllerImpl!.viewDidLoad(self)

        enchantmentPanel.axis = .horizontal
        enchantmentPanel.alignment = .center
        enchantmentPanel.distribution = .fill
        enchantmentPanel.spacing = 15

        do {
            let reduce = UIButton()
            reduce.translatesAutoresizingMaskIntoConstraints = false
            reduce.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            reduce.setTitle("➖", for: .normal)
            reduce.setTitleColor(.black, for: .normal)
            reduce.addTarget(self, action: #selector(enchantment_reduce(sender:)), for: .touchUpInside)
            enchantmentPanel.addArrangedSubview(reduce)

            let enlarge = UIButton()
            enlarge.translatesAutoresizingMaskIntoConstraints = false
            enlarge.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            enlarge.setTitle("➕", for: .normal)
            enlarge.setTitleColor(.black, for: .normal)
            enlarge.addTarget(self, action: #selector(enchantment_enlarge(sender:)), for: .touchUpInside)
            enchantmentPanel.addArrangedSubview(enlarge)

            let cancel = UIButton()
            cancel.translatesAutoresizingMaskIntoConstraints = false
            cancel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            cancel.setTitle("✘", for: .normal)
            cancel.setTitleColor(.black, for: .normal)
            cancel.addTarget(self, action: #selector(enchantment_cancel(sender:)), for: .touchUpInside)
            enchantmentPanel.addArrangedSubview(cancel)

            let ok = UIButton()
            ok.translatesAutoresizingMaskIntoConstraints = false
            ok.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            ok.setTitle("✔", for: .normal)
            ok.setTitleColor(.black, for: .normal)
            ok.addTarget(self, action: #selector(enchantment_ok(sender:)), for: .touchUpInside)
            enchantmentPanel.addArrangedSubview(ok)
        }

        enchantmentPanel.requestLayout()
        enchantmentPanel.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(enchantmentPanel)
        NSLayoutConstraint.activate([enchantmentPanel.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -15), enchantmentPanel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)])
        enchantmentPanel.isHidden = true

        markerPanel.axis = .horizontal
        markerPanel.alignment = .center
        markerPanel.distribution = .fill
        markerPanel.spacing = 15

        do {
            let cancel = UIButton()
            cancel.translatesAutoresizingMaskIntoConstraints = false
            cancel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            cancel.setTitle("✘", for: .normal)
            cancel.setTitleColor(.black, for: .normal)
            cancel.addTarget(self, action: #selector(marker_cancel(sender:)), for: .touchUpInside)
            markerPanel.addArrangedSubview(cancel)

            let ok = UIButton()
            ok.translatesAutoresizingMaskIntoConstraints = false
            ok.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            ok.setTitle("✔", for: .normal)
            ok.setTitleColor(.black, for: .normal)
            ok.addTarget(self, action: #selector(marker_ok(sender:)), for: .touchUpInside)
            markerPanel.addArrangedSubview(ok)
        }

        markerPanel.requestLayout()
        markerPanel.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(markerPanel)
        NSLayoutConstraint.activate([markerPanel.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -15), markerPanel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)])
        markerPanel.isHidden = true

        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mapControllerImpl!.viewWillAppear(self)
        cbkey = service!.openMap(channel!, cbkey, mapControllerImpl as! MapDataReceiver)
        channelCbkey = service!.addChannelChangedListener(channel!, channelCbkey, self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        service!.closeMap(channel: channel!, key: cbkey!)
        service!.removeChannelChangedListener(channel!, channelCbkey)
        mapControllerImpl!.viewWillDisappear(self)

        super.viewWillDisappear(animated)
    }

    func channelChanged() {
        mapControllerImpl?.channelChanged()
    }

    func getMapCenter() -> CLLocationCoordinate2D {
        return mapControllerImpl!.getMapCenter()
    }

    var searchResults = [SearchResult]()
    func setSearchResults(_ results: [SearchResult]) {
        searchResults = results
        mapControllerImpl?.updateSearchResults()
    }

    func moveToSearchResult(at: Int) {
        mapControllerImpl?.moveToSearchResult(at: at)
    }

    func moveTo(mate: Mate) {
        mapControllerImpl?.moveTo(mate: mate)
    }

    func moveTo(enchantment: Enchantment) {
        mapControllerImpl?.moveTo(enchantment: enchantment)
    }

    func moveTo(marker: Marker) {
        mapControllerImpl?.moveTo(marker: marker)
    }

    func enchantment_reduce(sender: UIButton) {
        editingEnchantmentRadiusIndex = max(0, editingEnchantmentRadiusIndex-1)
        mapControllerImpl!.refreshEditing()
    }

    func enchantment_enlarge(sender: UIButton) {
        editingEnchantmentRadiusIndex = min(Config.ENCHANTMENT_RADIUS.count-1, editingEnchantmentRadiusIndex+1)
        mapControllerImpl!.refreshEditing()
    }

    func enchantment_cancel(sender: UIButton) {
        refreshEditing(nil)
    }

    func enchantment_ok(sender: UIButton) {
        service!.createEnchantment(name: editingEnchantment.name!, channel_id: channel!.id!, ispublic: editingEnchantment.isPublic!, latitude: editingCoordinate.latitude, longitude: editingCoordinate.longitude, radius: Config.ENCHANTMENT_RADIUS[editingEnchantmentRadiusIndex], enable: true)
        refreshEditing(nil)
    }

    func marker_cancel(sender: UIButton) {
        refreshEditing(nil)
    }

    func marker_ok(sender: UIButton) {
        service!.createMarker(name: editingMarker.name!, channel_id: channel!.id!, ispublic: editingMarker.isPublic!, latitude: editingCoordinate.latitude, longitude: editingCoordinate.longitude, attr: editingMarker.attr!, enable: true)
        refreshEditing(nil)
    }

    override func didReceiveMemoryWarning() {
        mapControllerImpl!.didReceiveMemoryWarning()
        super.didReceiveMemoryWarning()
    }

    enum EditingType {
        case marker
        case enchantment
    }

    var editingType: EditingType?
    var editingCoordinate = CLLocationCoordinate2D()
    var editingEnchantmentRadiusIndex = Config.DEFAULT_ENCHANTMENT_RADIUS_INDEX
    var editingEnchantment = Enchantment()
    var editingMarker = Marker()
    func startEditing(_ coordinate: CLLocationCoordinate2D) {
        editingCoordinate = coordinate
        if editingType != nil {
            mapControllerImpl!.refreshEditing()
            return
        }

        _ = DialogStartEditing(self)
    }

    func refreshEditing(_ type: EditingType?) {
        if editingType == nil {
            editingEnchantmentRadiusIndex = Config.DEFAULT_ENCHANTMENT_RADIUS_INDEX
        }
        editingType = type
        if editingType == nil {
            enchantmentPanel.isHidden = true
            markerPanel.isHidden = true
        } else {
            switch editingType! {
            case .enchantment:
                enchantmentPanel.isHidden = false
                markerPanel.isHidden = true
            case .marker:
                enchantmentPanel.isHidden = true
                markerPanel.isHidden = false
            }
        }
        mapControllerImpl!.refreshEditing()
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
