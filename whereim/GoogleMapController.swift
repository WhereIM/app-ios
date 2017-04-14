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
    unowned var mapController: MapController
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var selfMate: Mate?
    var mapView: GMSMapView?

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

    func viewDidLoad(_ viewContrller: UIViewController) {
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView!.isMyLocationEnabled = true
        mapView!.settings.compassButton = true

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

    func viewWillAppear(_ viewContrller: UIViewController) {
        mapView!.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        mapView!.delegate = self
    }

    func viewWillDisappear(_ viewContrller: UIViewController) {
        mapView!.removeObserver(self, forKeyPath: "myLocation")
    }

    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        mapController.startEditing(coordinate)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !didFindMyLocation {
            let myLocation = change?[NSKeyValueChangeKey.newKey] as! CLLocation
            mapView!.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)
            mapView!.settings.myLocationButton = true

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
            c.position = mapController.editingCoordinate
            c.radius = CLLocationDistance(Config.ENCHANTMENT_RADIUS[mapController.editingEnchantmentRadiusIndex])
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
            m.position = mapController.editingCoordinate
            m.groundAnchor = CGPoint(x: 0.5, y: 1.0)
            m.icon = mapController.editingMarker.getIcon()
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
        }
        if enchantment.enabled == true || enchantment === focusEnchantment {
            let c = GMSCircle()
            c.position = CLLocationCoordinate2DMake(enchantment.latitude!, enchantment.longitude!)
            c.radius = enchantment.radius!
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
        if marker.deleted {
            self.markerMarker.removeValue(forKey: marker.id!)
        } else if marker.enabled == true || focusMarker === marker {
            let m = GMSMarker()
            m.position = CLLocationCoordinate2DMake(marker.latitude!, marker.longitude!)
            m.groundAnchor = CGPoint(x: 0.5, y: 1.0)
            m.title = marker.name
            m.icon = marker.getIcon()
            m.opacity = marker.enabled == true ? 1 : 0.5
            m.map = self.mapView

            self.markerMarker[marker.id!] = m

            if focus {
                mapView?.selectedMarker = m
            }
        }
    }

    func channelChanged() {
        updateSelfMate()
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
    func moveTo(marker: Marker?) {
        let exFocusMarker = focusMarker
        focusMarker = marker
        if exFocusMarker != nil {
            onMarkerData(exFocusMarker!)
        }
        if let m = marker {
            onMarkerData(m)
            mapView!.animate(toLocation: CLLocationCoordinate2DMake(m.latitude!, m.longitude!))
            if let mm = markerMarker[m.id!] {
                mapView!.selectedMarker = mm
            }
        }
    }

    var radiusCircle: GMSCircle?
    var mateCircle = [String:GMSCircle]()
    var mateMarker = [String:GMSMarker]()
    func onMateData(_ mate: Mate) {
        if let c = self.mateCircle[mate.id!] {
            if mate.latitude != nil {
                c.position = CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!)
                c.radius = mate.accuracy!
            } else {
                c.map = nil
                self.mateCircle.removeValue(forKey: mate.id!)
            }
        } else {
            if mate.latitude != nil {
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
            if mate.latitude != nil {
                m.position = CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!)
            } else {
                m.map = nil
                self.mateMarker.removeValue(forKey: mate.id!)
            }
        } else {
            if mate.latitude != nil {
                let m = GMSMarker()
                m.zIndex = 10
                m.position = CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!)
                m.groundAnchor = CGPoint(x: 0.5, y: 1.0)
                m.map = self.mapView
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
                c.radius = mapController.channel!.radius!
                if mapController.channel!.active == true {
                    c.strokeColor = .magenta
                } else {
                    c.strokeColor = .gray
                }
            } else {
                c.map = nil
            }
        } else {
            if selfMate!.latitude != nil && mapController.channel!.enable_radius==true {
                let c = GMSCircle()
                c.position = CLLocationCoordinate2DMake(selfMate!.latitude!, selfMate!.longitude!)
                c.radius = mapController.channel!.radius!
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

    func moveTo(mate: Mate) {
        if mate.latitude == nil {
            return
        }
        mapView!.animate(toLocation: CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!))
    }

    func didReceiveMemoryWarning() {
        // Dispose of any resources that can be recreated.
    }
}
