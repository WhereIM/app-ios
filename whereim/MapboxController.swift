//
//  MapboxController.swift
//  whereim
//
//  Created by Buganini Q on 25/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import UIKit
import Mapbox

class MapboxController: NSObject, MapControllerInterface, MGLMapViewDelegate, MapDataReceiver {
    unowned let mapController: MapController
    var didFindMyLocation = false
    var selfMate: Mate?
    let btnMyLocation = UIButton()
    var mapView: MGLMapView?
    var mapCenter = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var moveCameraToMyLocation = true
    let channelController: ChannelController

    required init(_ channelController: ChannelController, _ mapController: MapController) {
        self.channelController = channelController
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

    var pendingMarker: WimPointAnnotation?
    func viewDidLoad(_ viewContrller: UIViewController) {
        if let poi = mapController.service!.pendingPOI {
            moveCameraToMyLocation = false
            mapCenter = CLLocationCoordinate2D(latitude: poi.location!.latitude, longitude: poi.location!.longitude)
        }

        mapView = WimMapView()
        mapView!.setCenter(mapCenter, zoomLevel: 15, direction: 0, animated: false)
        mapView!.delegate = self
        mapView!.showsUserLocation = true

        mapView!.translatesAutoresizingMaskIntoConstraints = false
        viewContrller.view.addSubview(mapView!)

        let mapTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapDidTap))
        for recognizer in mapView!.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            mapTapGestureRecognizer.require(toFail: recognizer)
        }
        mapView!.addGestureRecognizer(mapTapGestureRecognizer)

        let mapLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapDidLongPress))
        mapView!.addGestureRecognizer(mapLongPressGestureRecognizer)

        NSLayoutConstraint.activate([
            mapView!.leftAnchor.constraint(equalTo: viewContrller.view.leftAnchor),
            mapView!.rightAnchor.constraint(equalTo: viewContrller.view.rightAnchor),
            mapView!.topAnchor.constraint(equalTo: viewContrller.topLayoutGuide.bottomAnchor),
            mapView!.bottomAnchor.constraint(equalTo: viewContrller.bottomLayoutGuide.topAnchor),
            ])

        btnMyLocation.translatesAutoresizingMaskIntoConstraints = false
        btnMyLocation.setImage(UIImage(named: "icon_gps_fixed"), for: .normal)
        btnMyLocation.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        btnMyLocation.layer.cornerRadius = 28
        btnMyLocation.addTarget(self, action: #selector(moveToMyLocation(sender:)), for: .touchUpInside)
        btnMyLocation.layer.shadowColor = UIColor.gray.cgColor
        btnMyLocation.layer.shadowOpacity = 1
        btnMyLocation.layer.shadowOffset = CGSize.init(width: 0, height: 2)
        btnMyLocation.layer.shadowRadius = 2

        viewContrller.view.addSubview(btnMyLocation)
        viewContrller.view.bringSubview(toFront: btnMyLocation)

        btnMyLocation.widthAnchor.constraint(equalToConstant: 56).isActive = true
        btnMyLocation.heightAnchor.constraint(equalToConstant: 56).isActive = true
        btnMyLocation.bottomAnchor.constraint(equalTo: viewContrller.bottomLayoutGuide.topAnchor, constant: -10).isActive = true
        btnMyLocation.rightAnchor.constraint(equalTo: viewContrller.view.rightAnchor, constant: -10).isActive = true
    }

    func viewDidAppear(_ viewController: UIViewController)  {
        if let poi = self.mapController.service!.pendingPOI {
            if pendingMarker != nil {
                mapView!.removeAnnotation(pendingMarker!)
                pendingMarker = nil
            }

            self.pendingMarker = WimPointAnnotation()
            self.pendingMarker!.coordinate = poi.location!
            self.pendingMarker!.title = poi.name!
            self.pendingMarker!.reuseId = "pending_poi"
            self.pendingMarker!.icon = UIImage(named: "search_marker")?.centerBottom()
            self.pendingMarker!.userData = poi
            self.mapView!.addAnnotation(self.pendingMarker!)

            self.mapController.tapMarker(poi)

            self.mapController.service!.pendingPOI = nil
        }
    }

    func viewWillAppear(_ viewContrller: UIViewController) {
    }

    func viewWillDisappear(_ viewContrller: UIViewController) {
    }

    @objc func moveToMyLocation(sender: Any) {
        if let ll = self.mapView?.userLocation?.coordinate {
            mapCenter = ll
            mapView!.setCenter(ll, zoomLevel: mapView!.zoomLevel, animated: true)
        }
    }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        if let m = annotation as? WimPolyline {
            return m.strokeColor
        }
        return UIColor.clear
    }

    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        if let m = annotation as? WimPolygon {
            return m.fillColor
        }
        return UIColor.clear
    }

    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        if let m = annotation as? WimPolygon {
            return m.opacity
        }
        return 1.0
    }

    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let m = annotation as? WimPointAnnotation {
            if annotation === pendingMarker {
                DispatchQueue.main.async {
                    self.mapView!.selectAnnotation(self.pendingMarker!, animated: false)
                }
            }
            let icon = m.icon!.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: m.icon!.size.height/2, right: 0))
            return MGLAnnotationImage(image: icon, reuseIdentifier: m.reuseId!)
        }
        return nil
    }

    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if let m = annotation as? WimPointAnnotation {
            m.selected = true
            if let obj = m.userData {
                if pendingMarker != nil && m.reuseId != "pending_poi" && m.reuseId != "pin" {
                    mapView.removeAnnotation(pendingMarker!)
                    pendingMarker = nil
                }
                mapController.clearActions(clearEditing: true)
                mapController.tapMarker(obj)
            }
        }
    }

    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        if let m = annotation as? WimPointAnnotation {
            m.selected = false
            mapController.tapMarker(nil)
        }
        mapController.clearActions(clearEditing: false)
    }

    @objc func mapDidTap(gesture: UITapGestureRecognizer) {
        if mapController.editingType != nil {
            return
        }
        if pendingMarker != nil {
            mapView!.removeAnnotation(pendingMarker!)
            pendingMarker = nil
        }
        mapController.clearActions(clearEditing: false)
    }

    @objc func mapDidLongPress(gesture: UILongPressGestureRecognizer) {
        mapController.clearActions(clearEditing: false)
        let p = gesture.location(in: mapView!)
        let coordinate: CLLocationCoordinate2D = mapView!.convert(p, toCoordinateFrom: mapView!)
        mapController.startEditing(coordinate, mapView!, p)
    }

    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        mapCenter = mapView.centerCoordinate
    }

    private var lastUserLocation: CLLocationCoordinate2D?
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        lastUserLocation = userLocation!.coordinate
        if !didFindMyLocation {
            if moveCameraToMyLocation {
                mapCenter = userLocation!.coordinate
                mapView.setCenter(userLocation!.coordinate, zoomLevel: 15, animated: true)
            }

            didFindMyLocation = true
        }
    }

    var editingEnchantmentCircle: WimPolyline?
    var editingMarkerMarker: WimPointAnnotation?
    func refreshEditing() {
        if mapController.editingType == .enchantment {
            if editingEnchantmentCircle != nil {
                self.mapView!.removeAnnotation(editingEnchantmentCircle!)
            }
            let cs = polygonCircleForCoordinate(coordinate: CLLocationCoordinate2D(latitude: mapController.editingEnchantment.latitude!, longitude: mapController.editingEnchantment.longitude!), withMeterRadius: Double(mapController.editingEnchantment.radius!))
            let c = WimPolyline(coordinates: cs, count: UInt(cs.count))
            if mapController.editingEnchantment.isPublic == true {
                c.strokeColor = .red
            } else {
                c.strokeColor = .orange
            }
            self.mapView!.addAnnotation(c)
            editingEnchantmentCircle = c
        } else {
            if editingEnchantmentCircle != nil {
                self.mapView!.removeAnnotation(editingEnchantmentCircle!)
            }
        }

        if mapController.editingType == .marker {
            if editingMarkerMarker != nil {
                self.mapView!.removeAnnotation(editingMarkerMarker!)
            }
            let m = WimPointAnnotation()
            m.coordinate = CLLocationCoordinate2D(latitude: mapController.editingMarker.latitude!, longitude: mapController.editingMarker.longitude!)
            m.icon = mapController.editingMarker.getIcon()
            m.zIndex = 100
            m.reuseId = mapController.editingMarker.getColor()
            self.mapView!.addAnnotation(m)
            editingMarkerMarker = m
        } else {
            if editingMarkerMarker != nil {
                self.mapView!.removeAnnotation(editingMarkerMarker!)
            }
        }
    }

    var enchantmentCircle = [String:WimPolyline]()
    func onEnchantmentData(_ enchantment: Enchantment) {
        if let c = self.enchantmentCircle[enchantment.id!] {
            self.mapView!.removeAnnotation(c)
            self.enchantmentCircle.removeValue(forKey: enchantment.id!)
        }
        if mapController.editingType == .enchantment && mapController.editingEnchantment.id == enchantment.id {
            return
        }
        if enchantment.enabled == true || enchantment === focusEnchantment {
            let cs = polygonCircleForCoordinate(coordinate: CLLocationCoordinate2DMake(enchantment.latitude!, enchantment.longitude!), withMeterRadius: Double(enchantment.radius!))
            let c = WimPolyline(coordinates: cs, count: UInt(cs.count))
            c.strokeColor = enchantment.enabled == true ? ( enchantment.isPublic == true ? .red : .orange ) : .gray
            self.mapView!.addAnnotation(c)

            self.enchantmentCircle[enchantment.id!] = c
        }
    }

    var markerMarker = [String:WimPointAnnotation]()
    func onMarkerData(_ marker: Marker) {
        var focus = false
        if let m = self.markerMarker[marker.id!] {
            if m.selected {
                focus = true
            }
            self.mapView!.removeAnnotation(m)
        }
        if mapController.editingType == .marker && mapController.editingMarker.id == marker.id {
            return
        }
        if marker.deleted {
            self.markerMarker.removeValue(forKey: marker.id!)
        } else if marker.enabled == true || focusMarker === marker {
            let m = WimPointAnnotation()
            m.coordinate = CLLocationCoordinate2DMake(marker.latitude!, marker.longitude!)
            m.title = marker.name
            m.opacity = marker.enabled == true ? 1 : 0.5
            m.icon = marker.getIcon().image(alpha: m.opacity)?.centerBottom()
            m.zIndex = 25
            m.userData = marker
            m.reuseId = "\(marker.getColor())/\(m.opacity)"
            self.mapView!.addAnnotation(m)

            self.markerMarker[marker.id!] = m

            if focus {
                self.mapView!.selectAnnotation(m, animated: false)
            }
        }
    }

    func channelChanged() {
        updateSelfMate()
    }

    func getMapCenter() -> CLLocationCoordinate2D {
        return mapCenter
    }

    var searchResultMarker = [WimPointAnnotation]()
    func updateSearchResults() {
        while searchResultMarker.count > 0 {
            let m = searchResultMarker.remove(at: 0)
            self.mapView!.removeAnnotation(m)
        }
        for r in channelController.searchResults {
            let m = WimPointAnnotation()
            m.coordinate = r.location!
            m.title = r.name!
            m.icon = UIImage(named: "search_marker")?.centerBottom()
            m.zIndex = 50
            m.userData = r
            m.reuseId = "search_marker"

            searchResultMarker.append(m)
        }
    }

    func moveToSearchResult(at: Int) {
        if at < channelController.searchResults.count {
            let r = channelController.searchResults[at]
            mapView!.setCenter(r.location!, animated: false)
        }
        if at < searchResultMarker.count {
            mapView!.selectAnnotation(searchResultMarker[at], animated: false)
            mapController.tapMarker(searchResultMarker[at].userData)
        }
    }

    func moveTo(pin location: CLLocationCoordinate2D) {
        if pendingMarker != nil {
            mapView!.removeAnnotation(pendingMarker!)
            pendingMarker = nil
        }

        self.pendingMarker = WimPointAnnotation()
        self.pendingMarker!.coordinate = location
        self.pendingMarker!.reuseId = "pin"
        self.pendingMarker!.icon = UIImage(named: "icon_pin")?.centerBottom()
        self.pendingMarker!.userData = location
        self.mapView!.addAnnotation(self.pendingMarker!)

        self.mapController.tapMarker(location)

        mapView?.setCenter(location, animated: false)
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
            mapView?.setCenter(CLLocationCoordinate2DMake(e.latitude!, e.longitude!), animated: false)
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
            mapView?.setCenter(CLLocationCoordinate2DMake(m.latitude!, m.longitude!), animated: false)
            if focus {
                if let mm = markerMarker[m.id!] {
                    mapView!.selectAnnotation(mm, animated: false)
                    mapController.tapMarker(mm.userData)
                }
            }
        }
    }

    var radiusCircle: WimPolyline?
    var mateName = [String:String]()
    var mateOpacity = [String:CGFloat]()
    var mateCircle = [String:WimPolygon]()
    var mateMarker = [String:WimPointAnnotation]()
    func onMateData(_ mate: Mate) {
        if let c = self.mateCircle[mate.id!] {
            self.mapView!.removeAnnotation(c)
            self.mateCircle.removeValue(forKey: mate.id!)
        }
        if mate.latitude != nil && !mate.deleted && (!mate.stale || focusMate === mate) {
            let cs = polygonCircleForCoordinate(coordinate: CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!), withMeterRadius: mate.accuracy!)
            let c = WimPolygon(coordinates: cs, count: UInt(cs.count))
            c.fillColor = UIColor.gray
            c.opacity = 0.25
            self.mapView!.addAnnotation(c)
            self.mateCircle[mate.id!] = c
        }
        if let m = self.mateMarker[mate.id!] {
            self.mapView!.removeAnnotation(m)
            self.mateMarker.removeValue(forKey: mate.id!)
        }
        if mate.latitude != nil && !mate.deleted && (!mate.stale || focusMate === mate) {
            let m = WimPointAnnotation()

            m.coordinate = CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!)
            m.opacity = mate.stale ? 0.5 : 1
            m.zIndex = 75

            mateName[mate.id!] = mate.getDisplayName()

            self.markerTemplateText.text = mate.getDisplayName()

            self.markerTemplate.frame = CGRect(x: 0, y: 0, width: max(self.markerTemplateText.intrinsicContentSize.width, self.markerTemplateIcon.intrinsicContentSize.width), height: self.markerTemplateText.intrinsicContentSize.height+self.markerTemplateIcon.intrinsicContentSize.height)

            UIGraphicsBeginImageContextWithOptions(self.markerTemplate.bounds.size, false, UIScreen.main.scale)
            if let currentContext = UIGraphicsGetCurrentContext()
            {
                self.markerTemplate.layer.render(in: currentContext)
                let imageMarker = UIGraphicsGetImageFromCurrentImageContext()!
                m.icon = imageMarker.image(alpha: m.opacity)?.centerBottom()
            }
            UIGraphicsEndImageContext()

            m.userData = mate
            m.reuseId = "\(mate.getDisplayName())/\(m.opacity)"
            self.mateMarker[mate.id!] = m
            self.mapView!.addAnnotation(m)
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
            self.mapView!.removeAnnotation(c)
            radiusCircle = nil
        }
        if selfMate!.latitude != nil && mapController.channel!.enable_radius==true {
            let cs = polygonCircleForCoordinate(coordinate: CLLocationCoordinate2DMake(selfMate!.latitude!, selfMate!.longitude!), withMeterRadius: Double(mapController.channel!.radius!))
            let c = WimPolyline(coordinates: cs, count: UInt(cs.count))
            if mapController.channel!.active == true {
                c.strokeColor = .magenta
            } else {
                c.strokeColor = .gray
            }
            self.mapView!.addAnnotation(c)
            radiusCircle = c
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
                mapView!.setCenter(CLLocationCoordinate2DMake(m.latitude!, m.longitude!), animated: false)
            }
            if let mm = mateMarker[m.id!] {
                mapView!.selectAnnotation(mm, animated: false)
                mapController.tapMarker(mm.userData)
            }
        }
    }
    
    func didReceiveMemoryWarning() {
        // Dispose of any resources that can be recreated.
    }
}
