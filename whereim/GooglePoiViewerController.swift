//
//  GoogleLocationViewerController.swift
//  whereim
//
//  Created by Buganini Q on 07/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import GoogleMaps

class GooglePoiViewerController: NSObject, PoiViewerControllerInterface {
    unowned let viewController: PoiViewerController
    var mapView: GMSMapView?

    required init(_ viewController: PoiViewerController) {
        self.viewController = viewController
    }

    func viewDidLoad(_ viewContrller: PoiViewerController) {
        let camera = GMSCameraPosition.camera(withLatitude: viewController.poi!.location!.latitude, longitude: viewController.poi!.location!.longitude, zoom: 15)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView!.settings.compassButton = true

        mapView!.translatesAutoresizingMaskIntoConstraints = false
        viewController.contentArea.addSubview(mapView!)

        NSLayoutConstraint.activate([
            mapView!.leftAnchor.constraint(equalTo: viewController.contentArea.leftAnchor),
            mapView!.rightAnchor.constraint(equalTo: viewController.contentArea.rightAnchor),
            mapView!.topAnchor.constraint(equalTo: viewController.contentArea.topAnchor),
            mapView!.bottomAnchor.constraint(equalTo: viewController.contentArea.bottomAnchor),
            ])

        let m = GMSMarker()
        m.position = viewController.poi!.location!
        m.title = viewController.poi?.name
        m.groundAnchor = CGPoint(x: 0.5, y: 1.0)
        m.icon = Marker.getIcon("red")
        m.map = self.mapView
        self.mapView?.selectedMarker = m
    }

    func viewWillAppear(_ viewContrller: PoiViewerController) {

    }

    func viewWillDisappear(_ viewContrller: PoiViewerController) {

    }

    func didReceiveMemoryWarning() {

    }
}
