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
        markerTemplateIcon.image = UIImage(named: "icon_mate.png")
        markerTemplateIcon.contentMode = .center
        markerTemplate.addArrangedSubview(markerTemplateText)
        markerTemplate.addArrangedSubview(markerTemplateIcon)
    }

    override func viewDidLoad() {
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 2)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView!.isMyLocationEnabled = true
        mapView!.accessibilityElementsHidden = false
        self.view = mapView

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
            mapView!.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
            mapView!.settings.myLocationButton = true

            didFindMyLocation = true
        }
    }

    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView!.isMyLocationEnabled = true
        }
    }

    var mateMarker = [String:GMSMarker]()
    func onMateData(_ mate: Mate) {
        if let marker = mateMarker[mate.id!] {
            if mate.latitude != nil {
                marker.position = CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!)
            }
        } else {
            DispatchQueue.main.async {
                if mate.latitude != nil {
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2DMake(mate.latitude!, mate.longitude!)
                    marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
                    marker.title = mate.mate_name
                    marker.map = self.mapView
                    self.markerTemplateText.text = mate.getDisplayName()

                    self.markerTemplate.frame = CGRect(x: 0, y: 0, width: max(self.markerTemplateText.intrinsicContentSize.width, self.markerTemplateIcon.intrinsicContentSize.width), height: self.markerTemplateText.intrinsicContentSize.height+self.markerTemplateIcon.intrinsicContentSize.height)

                    UIGraphicsBeginImageContextWithOptions(self.markerTemplate.bounds.size, false, UIScreen.main.scale)
                    if let currentContext = UIGraphicsGetCurrentContext()
                    {
                        self.markerTemplate.layer.render(in: currentContext)
                        var imageMarker = UIImage()
                        imageMarker = UIGraphicsGetImageFromCurrentImageContext()!
                        marker.icon = imageMarker
                    }
                    UIGraphicsEndImageContext()
                }
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
