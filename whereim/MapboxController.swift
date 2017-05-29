//
//  MapboxController.swift
//  whereim
//
//  Created by Buganini Q on 25/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import Mapbox

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

class WimPointAnnotation: MGLPointAnnotation {
    var userData: Any?
    var selected = false
    var icon: UIImage?
    var opacity = CGFloat(1.0)
    var zIndex = 0 // unused
}

class WimPolygon: MGLPolygon {
    var opacity = CGFloat(1.0)
    var fillColor = UIColor.clear
}

class WimPolyline: MGLPolyline {
    var strokeColor = UIColor.clear
}

// https://github.com/mapbox/mapbox-gl-native/issues/2167#issuecomment-192686761
func polygonCircleForCoordinate(coordinate: CLLocationCoordinate2D, withMeterRadius: Double) -> [CLLocationCoordinate2D] {
    let degreesBetweenPoints = 8.0
    let numberOfPoints = floor(360.0 / degreesBetweenPoints)
    let distRadians = withMeterRadius / 6371000.0
    let centerLatRadians = coordinate.latitude * Double.pi / 180
    let centerLonRadians = coordinate.longitude * Double.pi / 180
    var coordinates = [CLLocationCoordinate2D]()

    var i = 0
    while i < Int(numberOfPoints) {
        let degrees = Double(i) * Double(degreesBetweenPoints)
        let degreeRadians = degrees * Double.pi / 180
        let pointLatRadians = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
        let pointLonRadians = centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
        let pointLat = pointLatRadians * 180 / Double.pi
        let pointLon = pointLonRadians * 180 / Double.pi
        let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointLat, pointLon)
        print("circle point \(point)")
        coordinates.append(point)
        i += 1
    }
    coordinates.append(coordinates[0])

    return coordinates
}

class MapboxController: NSObject, MapControllerInterface, MGLMapViewDelegate, MapDataReceiver {
    unowned let mapController: MapController
    var didFindMyLocation = false
    var selfMate: Mate?
    var mapView: MGLMapView?
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

    var pendingMarker: WimPointAnnotation?
    func viewDidLoad(_ viewContrller: UIViewController) {
        if let poi = mapController.service!.pendingPOI {
            moveCameraToMyLocation = false
            mapCenter = CLLocationCoordinate2D(latitude: poi.location!.latitude, longitude: poi.location!.longitude)
        }

        mapView = MGLMapView()
        mapView!.setCenter(mapCenter, zoomLevel: 15, direction: 0, animated: false)
        mapView!.delegate = self
        mapView!.showsUserLocation = true

        mapView!.translatesAutoresizingMaskIntoConstraints = false
        viewContrller.view.addSubview(mapView!)

        NSLayoutConstraint.activate([
            mapView!.leftAnchor.constraint(equalTo: viewContrller.view.leftAnchor),
            mapView!.rightAnchor.constraint(equalTo: viewContrller.view.rightAnchor),
            mapView!.topAnchor.constraint(equalTo: viewContrller.topLayoutGuide.bottomAnchor),
            mapView!.bottomAnchor.constraint(equalTo: viewContrller.bottomLayoutGuide.topAnchor),
            ])
    }

    func viewDidAppear(_ viewController: UIViewController)  {
        if let poi = self.mapController.service!.pendingPOI {
            self.pendingMarker = WimPointAnnotation()
            self.pendingMarker!.coordinate = poi.location!
            self.pendingMarker!.title = poi.name!
            self.pendingMarker!.icon = UIImage(named: "search_marker")
            self.pendingMarker!.userData = poi
            self.mapView!.addAnnotation(self.pendingMarker!)

            self.mapController.tapMarker(poi)

            self.mapView!.selectAnnotation(self.pendingMarker!, animated: false)

            self.mapController.service!.pendingPOI = nil
        }
    }

    func viewWillAppear(_ viewContrller: UIViewController) {
    }

    func viewWillDisappear(_ viewContrller: UIViewController) {
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
            return MGLAnnotationImage(image: m.icon!, reuseIdentifier: m.hashValue.description)
        }
        return nil
    }

    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if let m = annotation as? WimPointAnnotation {
            m.selected = true
            mapController.tapMarker(m.userData)
        }
    }

    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        if let m = annotation as? WimPointAnnotation {
            m.selected = false
            mapController.tapMarker(nil)
        }
    }

//    func mapView(_ mapView: MGLMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        if pendingMarker != nil {
//            mapView.removeAnnotation(pendingMarker!)
//            pendingMarker = nil
//        }
//        mapController.clearActions()
//    }
//
//    func mapView(_ mapView: MGLMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
//        mapController.clearActions()
//        let p = mapView.projection.point(for: coordinate)
//        mapController.startEditing(coordinate, mapView, p)
//    }

    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        mapCenter = mapView.centerCoordinate
    }

    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if !didFindMyLocation {
            mapCenter = userLocation!.coordinate
            mapView.setCenter(userLocation!.coordinate, zoomLevel: 15, animated: true)

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
            let cs = polygonCircleForCoordinate(coordinate: mapController.editingCoordinate, withMeterRadius: Double(Config.ENCHANTMENT_RADIUS[mapController.editingEnchantmentRadiusIndex]))
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
            m.coordinate = mapController.editingCoordinate
            m.icon = mapController.editingMarker.getIcon()
            m.zIndex = 100
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
        if marker.deleted {
            self.markerMarker.removeValue(forKey: marker.id!)
        } else if marker.enabled == true || focusMarker === marker {
            let m = WimPointAnnotation()
            m.coordinate = CLLocationCoordinate2DMake(marker.latitude!, marker.longitude!)
            m.title = marker.name
            m.icon = marker.getIcon().image(alpha: marker.enabled == true ? 1 : 0.5)
            m.zIndex = 25
            m.userData = marker
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
        for r in mapController.searchResults {
            let m = WimPointAnnotation()
            m.coordinate = r.location!
            m.title = r.name!
            m.icon = UIImage(named: "search_marker")
            m.zIndex = 50
            m.userData = r

            searchResultMarker.append(m)
        }
    }

    func moveToSearchResult(at: Int) {
        if at < mapController.searchResults.count {
            let r = mapController.searchResults[at]
            mapView?.setCenter(r.location!, animated: false)
        }
        if at < searchResultMarker.count {
            mapView!.selectAnnotation(searchResultMarker[at], animated: false)
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
            mapView?.setCenter(CLLocationCoordinate2DMake(e.latitude!, e.longitude!), animated: false)
        }
    }

    private var focusMarker: Marker?
    func moveTo(marker: Marker?) {
        let exFocusMarker = focusMarker
        focusMarker = marker
        if exFocusMarker != nil {
            onMarkerData(exFocusMarker!)
        }
        if let m = marker {
            onMarkerData(m)
            mapView?.setCenter(CLLocationCoordinate2DMake(m.latitude!, m.longitude!), animated: false)
            if let mm = markerMarker[m.id!] {
                mapView!.selectAnnotation(mm, animated: false)
                mapController.tapMarker(mm.userData)
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
            if mate.latitude != nil && !mate.deleted && (!mate.stale || focusMate === mate) {
                m.coordinate = CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!)
                m.opacity = mate.stale ? 0.5 : 1

                if mateName[mate.id!] != mate.getDisplayName() || mateOpacity[mate.id!] != m.opacity {
                    mateName[mate.id!] = mate.getDisplayName()
                    mateOpacity[mate.id!] = m.opacity

                    self.markerTemplateText.text = mate.getDisplayName()

                    self.markerTemplate.frame = CGRect(x: 0, y: 0, width: max(self.markerTemplateText.intrinsicContentSize.width, self.markerTemplateIcon.intrinsicContentSize.width), height: self.markerTemplateText.intrinsicContentSize.height+self.markerTemplateIcon.intrinsicContentSize.height)

                    UIGraphicsBeginImageContextWithOptions(self.markerTemplate.bounds.size, false, UIScreen.main.scale)
                    if let currentContext = UIGraphicsGetCurrentContext()
                    {
                        self.markerTemplate.layer.render(in: currentContext)
                        var imageMarker = UIImage()
                        imageMarker = UIGraphicsGetImageFromCurrentImageContext()!
                        m.icon = imageMarker.image(alpha: m.opacity)
                    }
                    UIGraphicsEndImageContext()
                }
            } else {
                self.mapView!.removeAnnotation(m)
                self.mateMarker.removeValue(forKey: mate.id!)
            }
        } else {
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
                    var imageMarker = UIImage()
                    imageMarker = UIGraphicsGetImageFromCurrentImageContext()!
                    m.icon = imageMarker.image(alpha: m.opacity)
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
