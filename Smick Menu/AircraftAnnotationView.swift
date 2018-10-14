//
//  AircraftAnnotationView.swift
//  Smick Menu
//
//  Created by Omar Qazi on 10/5/18.
//  Copyright © 2018 Smick Enterprises, Inc. All rights reserved.
//

import UIKit
import MapKit

class AircraftAnnotationView: MKAnnotationView {
	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		self.isEnabled = false
		self.isDraggable = false
		self.image = UIImage(named: "aircraft")
	}
	
	required init(coder: NSCoder) {
		super.init(coder: coder)!
	}
	
	func updateHeading(heading: Float) {
		self.transform = CGAffineTransform.identity
		let cgHeading = CGFloat(heading)
		self.transform = CGAffineTransform(rotationAngle: cgHeading)
	}
}
