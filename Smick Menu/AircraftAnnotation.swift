//
//  AircraftAnnotation.swift
//  Smick Menu
//
//  Created by Omar Qazi on 10/5/18.
//  Copyright © 2018 Smick Enterprises, Inc. All rights reserved.
//

import UIKit
import MapKit

class AircraftAnnotation: NSObject, MKAnnotation {
	weak var annotationView: AircraftAnnotationView?
	
	dynamic var coordinate: CLLocationCoordinate2D
	dynamic var title: String?
	dynamic var subtitle: String?
	
	init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
		self.coordinate = coordinate
		self.title = title
		self.subtitle = subtitle
		
		super.init()
	}
	
	func updateHeading(heading: Float) {
		if let av = self.annotationView {
			av.updateHeading(heading: heading)
		}
	}
	
	
}
