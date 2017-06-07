//
//  MapboxPoiViewerController.swift
//  whereim
//
//  Created by Buganini Q on 07/06/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import Mapbox


class MapboxPoiViewerController: NSObject, MGLMapViewDelegate, PoiViewerControllerInterface {
    unowned let viewController: PoiViewerController
    var mapView: MGLMapView?
    var marker: WimPointAnnotation?

    required init(_ viewController: PoiViewerController) {
        self.viewController = viewController
    }

    func viewDidLoad(_ viewContrller: PoiViewerController) {
        let mapCenter = CLLocationCoordinate2D(latitude: viewController.poi!.location!.latitude, longitude: viewController.poi!.location!.longitude)
        mapView = WimMapView()
        mapView!.setCenter(mapCenter, zoomLevel: 15, direction: 0, animated: false)
        mapView!.delegate = self

        mapView!.translatesAutoresizingMaskIntoConstraints = false
        viewController.contentArea.addSubview(mapView!)

        NSLayoutConstraint.activate([
            mapView!.leftAnchor.constraint(equalTo: viewController.contentArea.leftAnchor),
            mapView!.rightAnchor.constraint(equalTo: viewController.contentArea.rightAnchor),
            mapView!.topAnchor.constraint(equalTo: viewController.contentArea.topAnchor),
            mapView!.bottomAnchor.constraint(equalTo: viewController.contentArea.bottomAnchor),
            ])

        marker = WimPointAnnotation()
        marker!.coordinate = viewController.poi!.location!
        marker!.title = viewController.poi?.name
        marker!.icon = Marker.getIcon("red").centerBottom()
        mapView!.addAnnotation(marker!)
    }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let m = annotation as? WimPointAnnotation {
            DispatchQueue.main.async {
                self.mapView!.selectAnnotation(self.marker!, animated: false)
            }

            let icon = m.icon!.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: m.icon!.size.height/2, right: 0))
            return MGLAnnotationImage(image: icon, reuseIdentifier: "poi")
        }
        return nil
    }

    func viewWillAppear(_ viewContrller: PoiViewerController) {

    }

    func viewWillDisappear(_ viewContrller: PoiViewerController) {

    }

    func didReceiveMemoryWarning() {

    }
}
