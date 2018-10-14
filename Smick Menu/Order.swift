//
//  Order.swift
//  Smick Menu
//
//  Created by Omar Qazi on 10/5/18.
//  Copyright © 2018 Smick Enterprises, Inc. All rights reserved.
//

import Foundation
import CoreLocation

struct Order {
	public var uuid: String = ""
	public var coordinates: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
	public var requestedItem: String = ""
	public var name: String = ""
}
