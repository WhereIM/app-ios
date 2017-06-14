//
//  MapController.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import UIKit

protocol MapControllerInterface: MapDataReceiver {
    init(_ mapController: MapController)
    func viewDidLoad(_ viewContrller: UIViewController)
    func viewWillAppear(_ viewContrller: UIViewController)
    func viewDidAppear(_ viewController: UIViewController)
    func viewWillDisappear(_ viewContrller: UIViewController)
    func didReceiveMemoryWarning()
    func channelChanged()
    func getMapCenter() -> CLLocationCoordinate2D
    func updateSearchResults()
    func moveToSearchResult(at: Int)
    func moveTo(mate: Mate?)
    func moveTo(marker: Marker?, focus: Bool)
    func moveTo(enchantment: Enchantment?)
    func refreshEditing()
}

class MapController: UIViewController, ChannelChangedListener, MapDataReceiver {
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
        switch Config.getMapProvider() {
        case .GOOGLE:
            mapControllerImpl = GoogleMapController(self)
        case .MAPBOX:
            mapControllerImpl = MapboxController(self)
        }
    }

    let enchantmentPanel = UIStackView()
    let radiusLabel = UILabel()

    let markerPanel = UIStackView()

    let markerActionsPanel = UIStackView()
    let createMarker = UIButton()
    let createEnchantment = UIButton()
    let share = UIButton()
    let openin = UIButton()

    override func viewDidLoad() {
        service = CoreService.bind()

        let parent = self.tabBarController as! ChannelController
        channel = parent.channel
        parent.setMapCtrl(self)

        mapControllerImpl!.viewDidLoad(self)

        enchantmentPanel.axis = .vertical
        enchantmentPanel.alignment = .center
        enchantmentPanel.distribution = .fill
        enchantmentPanel.spacing = 10
        enchantmentPanel.translatesAutoresizingMaskIntoConstraints = false

        do {
            radiusLabel.translatesAutoresizingMaskIntoConstraints = false
            radiusLabel.adjustsFontSizeToFitWidth = false
            enchantmentPanel.addArrangedSubview(radiusLabel)

            let actionsPanel = UIStackView()
            actionsPanel.axis = .horizontal
            actionsPanel.alignment = .center
            actionsPanel.distribution = .fill
            actionsPanel.spacing = 15
            actionsPanel.layoutMargins = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            actionsPanel.isLayoutMarginsRelativeArrangement = true
            actionsPanel.translatesAutoresizingMaskIntoConstraints = false
            enchantmentPanel.addArrangedSubview(actionsPanel)

            let background = UIView()
            background.translatesAutoresizingMaskIntoConstraints = false
            background.backgroundColor = UIColor.lightGray.withAlphaComponent(0.75)
            background.layer.cornerRadius = 15
            actionsPanel.insertSubview(background, at: 0)

            background.topAnchor.constraint(equalTo: actionsPanel.topAnchor).isActive = true
            background.leadingAnchor.constraint(equalTo: actionsPanel.leadingAnchor).isActive = true
            background.trailingAnchor.constraint(equalTo: actionsPanel.trailingAnchor).isActive = true
            background.bottomAnchor.constraint(equalTo: actionsPanel.bottomAnchor).isActive = true

            let reduce = UIButton()
            reduce.translatesAutoresizingMaskIntoConstraints = false
            reduce.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            reduce.setTitle("➖", for: .normal)
            reduce.setTitleColor(.black, for: .normal)
            reduce.addTarget(self, action: #selector(enchantment_reduce(sender:)), for: .touchUpInside)
            actionsPanel.addArrangedSubview(reduce)

            let enlarge = UIButton()
            enlarge.translatesAutoresizingMaskIntoConstraints = false
            enlarge.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            enlarge.setTitle("➕", for: .normal)
            enlarge.setTitleColor(.black, for: .normal)
            enlarge.addTarget(self, action: #selector(enchantment_enlarge(sender:)), for: .touchUpInside)
            actionsPanel.addArrangedSubview(enlarge)

            let cancel = UIButton()
            cancel.translatesAutoresizingMaskIntoConstraints = false
            cancel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            cancel.setTitle("✘", for: .normal)
            cancel.setTitleColor(.black, for: .normal)
            cancel.addTarget(self, action: #selector(enchantment_cancel(sender:)), for: .touchUpInside)
            actionsPanel.addArrangedSubview(cancel)

            let ok = UIButton()
            ok.translatesAutoresizingMaskIntoConstraints = false
            ok.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            ok.setTitle("✔", for: .normal)
            ok.setTitleColor(.black, for: .normal)
            ok.addTarget(self, action: #selector(enchantment_ok(sender:)), for: .touchUpInside)
            actionsPanel.addArrangedSubview(ok)
        }

        self.view.addSubview(enchantmentPanel)
        NSLayoutConstraint.activate([enchantmentPanel.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -15), enchantmentPanel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)])
        enchantmentPanel.isHidden = true

        markerPanel.axis = .horizontal
        markerPanel.alignment = .center
        markerPanel.distribution = .fill
        markerPanel.spacing = 15
        markerPanel.layoutMargins = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        markerPanel.isLayoutMarginsRelativeArrangement = true

        do {
            let background = UIView()
            background.translatesAutoresizingMaskIntoConstraints = false
            background.backgroundColor = UIColor.lightGray.withAlphaComponent(0.75)
            background.layer.cornerRadius = 15
            markerPanel.insertSubview(background, at: 0)

            background.topAnchor.constraint(equalTo: markerPanel.topAnchor).isActive = true
            background.leadingAnchor.constraint(equalTo: markerPanel.leadingAnchor).isActive = true
            background.trailingAnchor.constraint(equalTo: markerPanel.trailingAnchor).isActive = true
            background.bottomAnchor.constraint(equalTo: markerPanel.bottomAnchor).isActive = true

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

        markerPanel.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(markerPanel)
        NSLayoutConstraint.activate([markerPanel.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -15), markerPanel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)])
        markerPanel.isHidden = true

        markerActionsPanel.axis = .horizontal
        markerActionsPanel.alignment = .center
        markerActionsPanel.distribution = .fill
        markerActionsPanel.spacing = 15
        markerActionsPanel.layoutMargins = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        markerActionsPanel.isLayoutMarginsRelativeArrangement = true

        do {
            let background = UIView()
            background.translatesAutoresizingMaskIntoConstraints = false
            background.backgroundColor = UIColor.lightGray.withAlphaComponent(0.75)
            background.layer.cornerRadius = 15
            markerActionsPanel.insertSubview(background, at: 0)

            background.topAnchor.constraint(equalTo: markerActionsPanel.topAnchor).isActive = true
            background.leadingAnchor.constraint(equalTo: markerActionsPanel.leadingAnchor).isActive = true
            background.trailingAnchor.constraint(equalTo: markerActionsPanel.trailingAnchor).isActive = true
            background.bottomAnchor.constraint(equalTo: markerActionsPanel.bottomAnchor).isActive = true

            createMarker.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
            createMarker.setTitle("📍", for: .normal)
            createMarker.titleLabel?.font = createMarker.titleLabel?.font.withSize(28)
            markerActionsPanel.addArrangedSubview(createMarker)
            createMarker.addTarget(self, action: #selector(marker_create_marker(sender:)), for: .touchUpInside)

            createEnchantment.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
            createEnchantment.setTitle("⭕", for: .normal)
            createEnchantment.titleLabel?.font = createEnchantment.titleLabel?.font.withSize(28)
            markerActionsPanel.addArrangedSubview(createEnchantment)
            createEnchantment.addTarget(self, action: #selector(marker_create_enchantment(sender:)), for: .touchUpInside)

            share.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
            share.setTitle("✉️", for: .normal)
            share.titleLabel?.font = share.titleLabel?.font.withSize(28)
            markerActionsPanel.addArrangedSubview(share)
            share.addTarget(self, action: #selector(marker_share(sender:)), for: .touchUpInside)

            openin.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
            openin.setTitle("⤴️", for: .normal)
            openin.titleLabel?.font = openin.titleLabel?.font.withSize(28)
            markerActionsPanel.addArrangedSubview(openin)
            openin.addTarget(self, action: #selector(marker_openin(sender:)), for: .touchUpInside)
        }

        markerActionsPanel.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(markerActionsPanel)
        NSLayoutConstraint.activate([markerActionsPanel.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -15), markerActionsPanel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)])
        markerActionsPanel.isHidden = true

        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mapControllerImpl!.viewWillAppear(self)
        if let sv = service {
            channelCbkey = sv.addChannelChangedListener(channel!, channelCbkey, self)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        mapControllerImpl!.viewDidAppear(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let sv = service {
            sv.removeChannelChangedListener(channel!, channelCbkey)
        }
        mapControllerImpl!.viewWillDisappear(self)

        super.viewWillDisappear(animated)
    }

    func channelChanged() {
        mapControllerImpl?.channelChanged()
    }

    var focusMarkerLocation: CLLocationCoordinate2D?
    var focusMarkerTitle: String?
    func showMarkerActionsPanel(_ location: CLLocationCoordinate2D, _ title: String?, showCreateMarker: Bool, showCreateEnchantment: Bool, showShare: Bool, showOpenIn: Bool) {
        focusMarkerLocation = location
        focusMarkerTitle = title
        createMarker.isHidden = !showCreateMarker
        createEnchantment.isHidden = !showCreateEnchantment
        share.isHidden = !showShare
        openin.isHidden = !showOpenIn
        markerActionsPanel.isHidden = false
    }

    func clearActions(clearEditing: Bool) {
        if clearEditing {
            editingType = nil
            refreshEditing()
        }
        markerActionsPanel.isHidden = true
        markerPanel.isHidden = true
        enchantmentPanel.isHidden = true
    }

    func tapMarker(_ dataObj: Any?) {
        if let obj = dataObj {
            var title: String?
            var showCreateMarker = true
            var showCreateEnchantment = true
            var showShare = true
            var showOpenIn = true
            var location: CLLocationCoordinate2D?
            if obj is Marker {
                let marker = obj as! Marker
                title = marker.name
                location = CLLocationCoordinate2D(latitude: marker.latitude!, longitude: marker.longitude!)

                showCreateMarker = false
                showCreateEnchantment = true
                showShare = true
                showOpenIn = true
            } else if obj is Mate {
                let mate = obj as! Mate
                title = mate.getDisplayName()
                location = CLLocationCoordinate2D(latitude: mate.latitude!, longitude: mate.longitude!)

                showCreateMarker = true
                showCreateEnchantment = true
                showShare = true
                showOpenIn = true
            } else if obj is POI {
                let poi = obj as! POI
                title = poi.name
                location = poi.location

                showCreateMarker = true
                showCreateEnchantment = true
                showShare = true
                showOpenIn = true
            }
            showMarkerActionsPanel(location!, title, showCreateMarker: showCreateMarker, showCreateEnchantment: showCreateEnchantment, showShare: showShare, showOpenIn: showOpenIn)
        }
    }

    func getMapCenter() -> CLLocationCoordinate2D {
        return mapControllerImpl!.getMapCenter()
    }

    var searchResults = [POI]()
    func setSearchResults(_ results: [POI]) {
        searchResults = results
        mapControllerImpl?.updateSearchResults()
    }

    func moveToSearchResult(at: Int) {
        mapControllerImpl?.moveToSearchResult(at: at)
    }

    func moveTo(mate: Mate?, focus: Bool) {
        mapControllerImpl?.moveTo(mate: mate)
    }

    func moveTo(enchantment: Enchantment, focus: Bool) {
        mapControllerImpl?.moveTo(enchantment: enchantment)
    }

    func moveTo(marker: Marker, focus: Bool) {
        mapControllerImpl?.moveTo(marker: marker, focus: true)
    }

    func edit(enchantment: Enchantment, name: String, shared: Bool) {
        clearActions(clearEditing: true)
        editingEnchantmentOrig = enchantment
        editingType = EditingType.enchantment
        editingEnchantment.id = enchantment.id
        editingEnchantment.name = name
        editingEnchantment.latitude = enchantment.latitude
        editingEnchantment.longitude = enchantment.longitude
        editingEnchantment.radius = enchantment.radius!
        editingEnchantment.isPublic = shared
        mapControllerImpl!.moveTo(enchantment: editingEnchantment)
        refreshEditing()
    }

    func edit(marker: Marker, name: String, attr: [String:Any], shared: Bool) {
        clearActions(clearEditing: true)
        editingMarkerOrig = marker
        editingType = EditingType.marker
        editingMarker.id = marker.id
        editingMarker.name = name
        editingMarker.latitude = marker.latitude
        editingMarker.longitude = marker.longitude
        editingMarker.attr = attr
        editingMarker.isPublic = shared
        mapControllerImpl!.moveTo(marker: editingMarker, focus: false)
        refreshEditing()
    }

    func enchantment_reduce(sender: UIButton) {
        editingEnchantment.radius! -= Config.getStep(radius: editingEnchantment.radius!)
        editingEnchantment.radius! = min(Config.ENCHANTMENT_RADIUS_MAX ,max(Config.ENCHANTMENT_RADIUS_MIN, editingEnchantment.radius!))
        radiusLabel.text = String(format: "radius_m".localized, editingEnchantment.radius!)
        refreshEditing()
    }

    func enchantment_enlarge(sender: UIButton) {
        editingEnchantment.radius! += Config.getStep(radius: editingEnchantment.radius!)
        editingEnchantment.radius! = min(Config.ENCHANTMENT_RADIUS_MAX ,max(Config.ENCHANTMENT_RADIUS_MIN, editingEnchantment.radius!))
        radiusLabel.text = String(format: "radius_m".localized, editingEnchantment.radius!)
        refreshEditing()
    }

    func enchantment_cancel(sender: UIButton) {
        editingType = nil
        if let orig = editingEnchantmentOrig {
            onEnchantmentData(orig)
            editingEnchantmentOrig = nil
        }
        refreshEditing()
    }

    func enchantment_ok(sender: UIButton) {
        editingEnchantment.channel_id = channel!.id!
        service!.set(enchantment: editingEnchantment)
        editingType = nil
        refreshEditing()
    }

    func marker_create_marker(sender: UIButton) {
        clearActions(clearEditing: true)
        editingCoordinate = focusMarkerLocation!
        _ = DialogCreateMarker(self, focusMarkerTitle)
    }

    func marker_create_enchantment(sender: UIButton) {
        clearActions(clearEditing: true)
        editingCoordinate = focusMarkerLocation!
        _ = DialogCreateEnchantment(self, focusMarkerTitle)
    }

    func marker_share(sender: UIButton) {
        _ = DialogShareLocation(self, focusMarkerLocation!, focusMarkerTitle, sender, nil)
    }

    func marker_openin(sender: UIButton) {
        _ = DialogOpenIn(self, focusMarkerLocation!, focusMarkerTitle, sender, nil)
    }

    func marker_cancel(sender: UIButton) {
        editingType = nil
        if let orig = editingMarkerOrig {
            onMarkerData(orig)
            editingMarkerOrig = nil
        }
        refreshEditing()
    }

    func marker_ok(sender: UIButton) {
        editingMarker.channel_id = channel!.id!
        service!.set(marker: editingMarker)
        editingType = nil
        refreshEditing()
    }

    override func didReceiveMemoryWarning() {
        mapControllerImpl!.didReceiveMemoryWarning()
        super.didReceiveMemoryWarning()
    }

    public enum EditingType {
        case marker
        case enchantment
    }

    var editingType: EditingType?
    var editingCoordinate = CLLocationCoordinate2D()
    var editingEnchantmentOrig: Enchantment?
    var editingMarkerOrig: Marker?
    var editingEnchantment = Enchantment()
    var editingMarker = Marker()
    func startEditing(_ coordinate: CLLocationCoordinate2D, _ mapView: UIView, _ touchPosition: CGPoint) {
        editingCoordinate = coordinate
        if editingType != nil {
            switch editingType! {
            case .enchantment:
                editingEnchantment.latitude = editingCoordinate.latitude
                editingEnchantment.longitude = editingCoordinate.longitude
            case .marker:
                editingMarker.latitude = editingCoordinate.latitude
                editingMarker.longitude = editingCoordinate.longitude
            }
            refreshEditing()
            return
        }

        _ = DialogMapMenu(self, mapView, touchPosition)
    }

    func refreshEditing() {
        if editingType == nil {
            enchantmentPanel.isHidden = true
            markerPanel.isHidden = true
        } else {
            switch editingType! {
            case .enchantment:
                enchantmentPanel.isHidden = false
                markerPanel.isHidden = true
                radiusLabel.text = String(format: "radius_m".localized, editingEnchantment.radius!)
            case .marker:
                enchantmentPanel.isHidden = true
                markerPanel.isHidden = false
            }
        }
        mapControllerImpl!.refreshEditing()
    }

    func onMateData(_ mate: Mate) {
        mapControllerImpl!.onMateData(mate)
    }

    func onMarkerData(_ marker: Marker) {
        mapControllerImpl!.onMarkerData(marker)
    }

    func onEnchantmentData(_ enchantment: Enchantment) {
        mapControllerImpl!.onEnchantmentData(enchantment)
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
