//
//  MapboxUtils.swift
//  whereim
//
//  Created by Buganini Q on 07/06/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import Mapbox
import UIKit

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
        coordinates.append(point)
        i += 1
    }
    coordinates.append(coordinates[0])

    return coordinates
}


class WimPointAnnotation: MGLPointAnnotation {
    var userData: Any?
    var selected = false
    var icon: UIImage?
    var opacity = CGFloat(1.0)
    var reuseId: String?
    var zIndex = 0 // unused
}

class WimPolygon: MGLPolygon {
    var opacity = CGFloat(1.0)
    var fillColor = UIColor.clear
}

class WimPolyline: MGLPolyline {
    var strokeColor = UIColor.clear
}

class WimMapView: MGLMapView {
    override func updateConstraints() {
        super.updateConstraints()

        for constraint in constraints {
            if constraint.secondItem as? UIButton == attributionButton {
                constraint.isActive = false
            }
        }
        self.attributionButton.leadingAnchor.constraint(equalTo: self.logoView.trailingAnchor, constant: 8).isActive = true
        self.attributionButton.centerYAnchor.constraint(equalTo: self.logoView.centerYAnchor).isActive = true
    }
}
