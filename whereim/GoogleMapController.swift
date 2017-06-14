//
//  GoogleMapController.swift
//  whereim
//
//  Created by Buganini Q on 19/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMapController: NSObject, MapControllerInterface, GMSMapViewDelegate, CLLocationManagerDelegate, MapDataReceiver {
    unowned let mapController: MapController
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var selfMate: Mate?
    var mapView: GMSMapView?
    var mapCenter = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var moveCameraToMyLocation = true

    required init(_ mapController: MapController) {
        self.mapController = mapController
        super.init()
        initmarkerTamplate()
    }

    var markerTemplate = UIStackView()
    var markerTemplateText = UILabel()
    var markerTemplateIcon = UIImageView()
    func initmarkerTamplate() {
        markerTemplate.axis = .vertical
        markerTemplate.alignment = .center
        markerTemplate.distribution = .fill
        markerTemplateText.adjustsFontSizeToFitWidth = false
        markerTemplateIcon.image = UIImage(named: "icon_mate")
        markerTemplateIcon.contentMode = .center
        markerTemplate.addArrangedSubview(markerTemplateText)
        markerTemplate.addArrangedSubview(markerTemplateIcon)
    }

    var pendingMarker: GMSMarker?
    func viewDidLoad(_ viewContrller: UIViewController) {
        if let poi = mapController.service!.pendingPOI {
            moveCameraToMyLocation = false
            mapCenter = CLLocationCoordinate2D(latitude: poi.location!.latitude, longitude: poi.location!.longitude)
        }

        let camera = GMSCameraPosition.camera(withLatitude: mapCenter.latitude, longitude: mapCenter.longitude, zoom: 15)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView!.settings.compassButton = true
        mapView!.settings.myLocationButton = true

        mapView!.translatesAutoresizingMaskIntoConstraints = false
        viewContrller.view.addSubview(mapView!)

        NSLayoutConstraint.activate([
            mapView!.leftAnchor.constraint(equalTo: viewContrller.view.leftAnchor),
            mapView!.rightAnchor.constraint(equalTo: viewContrller.view.rightAnchor),
            mapView!.topAnchor.constraint(equalTo: viewContrller.topLayoutGuide.bottomAnchor),
            mapView!.bottomAnchor.constraint(equalTo: viewContrller.bottomLayoutGuide.topAnchor),
            ])

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

    func viewDidAppear(_ viewController: UIViewController) {
        if let poi = self.mapController.service!.pendingPOI {
            self.pendingMarker = GMSMarker()
            self.pendingMarker!.position = poi.location!
            self.pendingMarker!.groundAnchor = CGPoint(x: 0.5, y: 1.0)
            self.pendingMarker!.title = poi.name!
            self.pendingMarker!.icon = UIImage(named: "search_marker")
            self.pendingMarker!.zIndex = 50
            self.pendingMarker!.map = self.mapView
            self.pendingMarker!.userData = poi

            self.mapController.tapMarker(poi)

            self.mapView?.selectedMarker = self.pendingMarker

            self.mapController.service!.pendingPOI = nil
        }
    }

    func viewWillAppear(_ viewContrller: UIViewController) {
        mapView!.isMyLocationEnabled = true
        if moveCameraToMyLocation {
            mapView!.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        }
        mapView!.delegate = self
    }

    func viewWillDisappear(_ viewContrller: UIViewController) {
        if moveCameraToMyLocation {
            mapView!.removeObserver(self, forKeyPath: "myLocation")
        }
        mapView!.isMyLocationEnabled = false
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let obj = marker.userData {
            if pendingMarker != nil {
                pendingMarker!.map = nil
                pendingMarker = nil
            }
            mapController.clearActions(clearEditing: true)
            mapController.tapMarker(obj)
        }
        return false
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if mapController.editingType != nil {
            return
        }
        if pendingMarker != nil {
            pendingMarker!.map = nil
            pendingMarker = nil
        }
        mapController.clearActions(clearEditing: false)
    }

    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        mapController.clearActions(clearEditing: false)
        let p = mapView.projection.point(for: coordinate)
        mapController.startEditing(coordinate, mapView, p)
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mapCenter = position.target
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !didFindMyLocation {
            let myLocation = change?[NSKeyValueChangeKey.newKey] as! CLLocation
            mapCenter = myLocation.coordinate
            mapView!.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)

            didFindMyLocation = true
        }
    }

    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView!.isMyLocationEnabled = true
        }
    }

    var editingEnchantmentCircle: GMSCircle?
    var editingMarkerMarker: GMSMarker?
    func refreshEditing() {
        if mapController.editingType == .enchantment {
            if editingEnchantmentCircle != nil {
                editingEnchantmentCircle!.map = nil
            }
            let c = GMSCircle()
            c.position = CLLocationCoordinate2D(latitude: mapController.editingEnchantment.latitude!, longitude: mapController.editingEnchantment.longitude!)
            c.radius = Double(mapController.editingEnchantment.radius!)
            c.strokeWidth = 3
            if mapController.editingEnchantment.isPublic == true {
                c.strokeColor = .red
            } else {
                c.strokeColor = .orange
            }
            c.map = self.mapView
            editingEnchantmentCircle = c
        } else {
            if editingEnchantmentCircle != nil {
                editingEnchantmentCircle!.map = nil
            }
        }

        if mapController.editingType == .marker {
            if editingMarkerMarker != nil {
                editingMarkerMarker!.map = nil
            }
            let m = GMSMarker()
            m.position = CLLocationCoordinate2D(latitude: mapController.editingMarker.latitude!, longitude: mapController.editingMarker.longitude!)
            m.groundAnchor = CGPoint(x: 0.5, y: 1.0)
            m.icon = mapController.editingMarker.getIcon()
            m.zIndex = 100
            m.map = self.mapView
            editingMarkerMarker = m
        } else {
            if editingMarkerMarker != nil {
                editingMarkerMarker!.map = nil
            }
        }
    }

    var enchantmentCircle = [String:GMSCircle]()
    func onEnchantmentData(_ enchantment: Enchantment) {
        if let c = self.enchantmentCircle[enchantment.id!] {
            c.map = nil
            self.enchantmentCircle.removeValue(forKey: enchantment.id!)
        }
        if mapController.editingType == .enchantment && mapController.editingEnchantment.id == enchantment.id {
            return
        }
        if enchantment.enabled == true || enchantment === focusEnchantment {
            let c = GMSCircle()
            c.position = CLLocationCoordinate2DMake(enchantment.latitude!, enchantment.longitude!)
            c.radius = CLLocationDistance(enchantment.radius!)
            c.strokeWidth = 3
            c.strokeColor = enchantment.enabled == true ? ( enchantment.isPublic == true ? .red : .orange ) : .gray
            c.map = self.mapView

            self.enchantmentCircle[enchantment.id!] = c
        }
    }

    var markerMarker = [String:GMSMarker]()
    func onMarkerData(_ marker: Marker) {
        var focus = false
        if let m = self.markerMarker[marker.id!] {
            if m == mapView!.selectedMarker {
                focus = true
            }
            m.map = nil
        }
        if mapController.editingType == .marker && mapController.editingMarker.id == marker.id {
            return
        }
        if marker.deleted {
            self.markerMarker.removeValue(forKey: marker.id!)
        } else if marker.enabled == true || focusMarker === marker {
            let m = GMSMarker()
            m.position = CLLocationCoordinate2DMake(marker.latitude!, marker.longitude!)
            m.groundAnchor = CGPoint(x: 0.5, y: 1.0)
            m.title = marker.name
            m.icon = marker.getIcon()
            m.opacity = marker.enabled == true ? 1 : 0.5
            m.zIndex = 25
            m.map = self.mapView

            self.markerMarker[marker.id!] = m
            m.userData = marker

            if focus {
                mapView?.selectedMarker = m
            }
        }
    }

    func channelChanged() {
        updateSelfMate()
    }

    func getMapCenter() -> CLLocationCoordinate2D {
        return mapCenter
    }

    var searchResultMarker = [GMSMarker]()
    func updateSearchResults() {
        while searchResultMarker.count > 0 {
            let m = searchResultMarker.remove(at: 0)
            m.map = nil
        }
        for r in mapController.searchResults {
            let m = GMSMarker()
            m.position = r.location!
            m.groundAnchor = CGPoint(x: 0.5, y: 1.0)
            m.title = r.name!
            m.icon = UIImage(named: "search_marker")
            m.zIndex = 50
            m.map = self.mapView
            m.userData = r

            searchResultMarker.append(m)
        }
    }

    func moveToSearchResult(at: Int) {
        if at < mapController.searchResults.count {
            let r = mapController.searchResults[at]
            mapView!.animate(toLocation: r.location!)
        }
        if at < searchResultMarker.count {
            mapView!.selectedMarker = searchResultMarker[at]
            mapController.tapMarker(searchResultMarker[at].userData)
        }
    }

    private var focusEnchantment: Enchantment?
    func moveTo(enchantment: Enchantment?) {
        let exFocusEnchantment = focusEnchantment
        focusEnchantment = enchantment
        if exFocusEnchantment != nil {
            onEnchantmentData(exFocusEnchantment!)
        }
        if let e = enchantment {
            onEnchantmentData(e)
            mapView!.animate(toLocation: CLLocationCoordinate2DMake(e.latitude!, e.longitude!))
        }
    }

    private var focusMarker: Marker?
    func moveTo(marker: Marker?, focus: Bool) {
        let exFocusMarker = focusMarker
        focusMarker = marker
        if exFocusMarker != nil {
            onMarkerData(exFocusMarker!)
        }
        if let m = marker {
            onMarkerData(m)
            mapView!.animate(toLocation: CLLocationCoordinate2DMake(m.latitude!, m.longitude!))
            if focus {
                if let mm = markerMarker[m.id!] {
                    mapView!.selectedMarker = mm
                    mapController.tapMarker(mm.userData)
                }
            }
        }
    }

    var radiusCircle: GMSCircle?
    var mateName = [String:String]()
    var mateCircle = [String:GMSCircle]()
    var mateMarker = [String:GMSMarker]()
    func onMateData(_ mate: Mate) {
        if let c = self.mateCircle[mate.id!] {
            if mate.latitude != nil && !mate.deleted && (!mate.stale || focusMate === mate) {
                c.position = CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!)
                c.radius = mate.accuracy!
            } else {
                c.map = nil
                self.mateCircle.removeValue(forKey: mate.id!)
            }
        } else {
            if mate.latitude != nil && !mate.deleted && (!mate.stale || focusMate === mate) {
                let c = GMSCircle()
                c.position = CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!)
                c.radius = mate.accuracy!
                c.strokeColor = .clear
                c.fillColor = UIColor.gray.withAlphaComponent(0.25)
                c.map = self.mapView
                self.mateCircle[mate.id!] = c
            }
        }
        if let m = self.mateMarker[mate.id!] {
            if mate.latitude != nil && !mate.deleted && (!mate.stale || focusMate === mate) {
                m.position = CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!)
                m.opacity = mate.stale ? 0.5 : 1

                if mateName[mate.id!] != mate.getDisplayName() {
                    mateName[mate.id!] = mate.getDisplayName()

                    self.markerTemplateText.text = mate.getDisplayName()

                    self.markerTemplate.frame = CGRect(x: 0, y: 0, width: max(self.markerTemplateText.intrinsicContentSize.width, self.markerTemplateIcon.intrinsicContentSize.width), height: self.markerTemplateText.intrinsicContentSize.height+self.markerTemplateIcon.intrinsicContentSize.height)

                    UIGraphicsBeginImageContextWithOptions(self.markerTemplate.bounds.size, false, UIScreen.main.scale)
                    if let currentContext = UIGraphicsGetCurrentContext()
                    {
                        self.markerTemplate.layer.render(in: currentContext)
                        var imageMarker = UIImage()
                        imageMarker = UIGraphicsGetImageFromCurrentImageContext()!
                        m.icon = imageMarker
                    }
                    UIGraphicsEndImageContext()
                }
            } else {
                m.map = nil
                self.mateMarker.removeValue(forKey: mate.id!)
            }
        } else {
            if mate.latitude != nil && !mate.deleted && (!mate.stale || focusMate === mate) {
                let m = GMSMarker()
                m.zIndex = 75
                m.position = CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!)
                m.groundAnchor = CGPoint(x: 0.5, y: 1.0)
                m.opacity = mate.stale ? 0.5 : 1
                m.map = self.mapView

                mateName[mate.id!] = mate.getDisplayName()

                self.markerTemplateText.text = mate.getDisplayName()

                self.markerTemplate.frame = CGRect(x: 0, y: 0, width: max(self.markerTemplateText.intrinsicContentSize.width, self.markerTemplateIcon.intrinsicContentSize.width), height: self.markerTemplateText.intrinsicContentSize.height+self.markerTemplateIcon.intrinsicContentSize.height)

                UIGraphicsBeginImageContextWithOptions(self.markerTemplate.bounds.size, false, UIScreen.main.scale)
                if let currentContext = UIGraphicsGetCurrentContext()
                {
                    self.markerTemplate.layer.render(in: currentContext)
                    var imageMarker = UIImage()
                    imageMarker = UIGraphicsGetImageFromCurrentImageContext()!
                    m.icon = imageMarker
                }
                UIGraphicsEndImageContext()

                self.mateMarker[mate.id!] = m
                m.userData = mate
            }
        }
        if mate.id! == mapController.channel!.mate_id! {
            selfMate = mate
            updateSelfMate()
        }
    }

    func updateSelfMate() {
        if selfMate == nil {
            return
        }
        if let c = radiusCircle {
            if selfMate!.latitude != nil && mapController.channel!.enable_radius==true {
                c.position = CLLocationCoordinate2DMake(selfMate!.latitude!, selfMate!.longitude!)
                c.radius = CLLocationDistance(mapController.channel!.radius!)
                if mapController.channel!.active == true {
                    c.strokeColor = .magenta
                } else {
                    c.strokeColor = .gray
                }
            } else {
                c.map = nil
                radiusCircle = nil
            }
        } else {
            if selfMate!.latitude != nil && mapController.channel!.enable_radius==true {
                let c = GMSCircle()
                c.position = CLLocationCoordinate2DMake(selfMate!.latitude!, selfMate!.longitude!)
                c.radius = CLLocationDistance(mapController.channel!.radius!)
                c.strokeWidth = 3
                if mapController.channel!.active == true {
                    c.strokeColor = .magenta
                } else {
                    c.strokeColor = .gray
                }
                c.map = self.mapView
                radiusCircle = c
            }
        }
    }

    private var focusMate: Mate?
    func moveTo(mate: Mate?) {
        let exFocusMate = focusMate
        focusMate = mate
        if exFocusMate != nil {
            onMateData(exFocusMate!)
        }
        if let m = mate {
            onMateData(m)
            if m.latitude != nil && m.longitude != nil {
                mapView!.animate(toLocation: CLLocationCoordinate2DMake(m.latitude!, m.longitude!))
            }
            if let mm = mateMarker[m.id!] {
                mapView!.selectedMarker = mm
                mapController.tapMarker(mm.userData)
            }
        }
    }

    func didReceiveMemoryWarning() {
        // Dispose of any resources that can be recreated.
    }
}
