//
//  GoogleMapController.swift
//  whereim
//
//  Created by Buganini Q on 19/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMapController: MapController, CLLocationManagerDelegate, MapDataReceiver {

    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var mapView: GMSMapView?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initmarkerTamplate()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
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

    override func viewDidLoad() {
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView!.isMyLocationEnabled = true
        mapView!.settings.compassButton = true

        mapView!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView!)

        NSLayoutConstraint.activate([
            mapView!.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            mapView!.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            mapView!.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
            mapView!.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor),
            ])
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        mapView!.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
    }

    deinit {
        mapView!.removeObserver(self, forKeyPath: "myLocation")

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

    var enchantmentCirclr = [String:GMSCircle]()
    func onEnchantmentData(_ enchantment: Enchantment) {
        if let c = self.enchantmentCirclr[enchantment.id!] {
            c.map = nil
        }
        if enchantment.enable == true {
            let c = GMSCircle()
            c.position = CLLocationCoordinate2DMake(enchantment.latitude!, enchantment.longitude!)
            c.radius = enchantment.radius!
            c.strokeColor = .red
            c.map = self.mapView

            self.enchantmentCirclr[enchantment.id!] = c
        }
    }

    var markerMarker = [String:GMSMarker]()
    func onMarkerData(_ marker: Marker) {
        if let m = self.markerMarker[marker.id!] {
            m.map = nil
        }
        if marker.enable == true {
            let m = GMSMarker()
            m.position = CLLocationCoordinate2DMake(marker.latitude!, marker.longitude!)
            m.groundAnchor = CGPoint(x: 0.5, y: 1.0)
            m.title = marker.name
            m.icon = marker.getIcon()
            m.map = self.mapView

            self.markerMarker[marker.id!] = m
        }
    }

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
                c.strokeColor = .blue
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
