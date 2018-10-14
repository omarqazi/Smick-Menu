//
//  OrderViewController.swift
//  Smick Menu
//
//  Created by Omar Qazi on 9/30/18.
//  Copyright © 2018 Smick Enterprises, Inc. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire

class OrderViewController: UIViewController, CLLocationManagerDelegate {
	@IBOutlet var mapView: MKMapView?
	@IBOutlet var nameField: UITextField?
	@IBOutlet var orderField: UITextField?
	@IBOutlet var summaryField: UITextField?
	var orderSummary: String = ""
	
	var userDefaults = UserDefaults(suiteName: "SmickMenu")
	
	var locationManager: CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		self.nameField?.text = self.userDefaults?.string(forKey: "user-full-name")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.locationManager.delegate = self
		self.locationManager.requestAlwaysAuthorization()
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		self.locationManager.startUpdatingLocation()
		self.mapView?.showsUserLocation = true
		self.mapView?.userTrackingMode = .follow
		self.summaryField?.text = self.orderSummary
		
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
	}
	
	@IBAction func finishedWithName(sender: UITextField) {
		if let userFullName = self.nameField?.text {
			if userFullName.count > 0 {
				self.userDefaults?.set(userFullName, forKey: "user-full-name")
			}
		}
		
		self.orderField?.becomeFirstResponder()
	}
	
	@IBAction func finishedWithOrder(sender: UITextField) {
		self.orderField?.resignFirstResponder()
	}
	
	@IBAction func submitOrder(sender: AnyObject) {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

		var orderName: String = ""
		var orderDescription: String = ""
		if let enteredName = self.nameField?.text {
			orderName = enteredName
		}
		
		if let enteredOrder = self.orderField?.text {
			orderDescription = enteredOrder
		}
		
		var currentCoordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
		if let currentLocation = self.locationManager.location {
			currentCoordinates = currentLocation.coordinate
		} else {
			let errorView = UIAlertController(title: "Cant Find You", message: "There was an error trying to find your location for the order. Please make sure this app is allowed to access your location and try again.", preferredStyle: .alert)
			let alertAction = UIAlertAction(title: "Try Again", style: .default) { (ac) in
				errorView.dismiss(animated: true, completion: {})
			}
			errorView.addAction(alertAction)
			self.present(errorView, animated: true) {
				self.locationManager.startUpdatingLocation()
			}
			return
		}
		
		let newOrder: [String : Any] = [
			"Latitude" : currentCoordinates.latitude,
			"Longitude" : currentCoordinates.longitude,
			"Name" : orderName,
			"OrderDescription" : orderDescription
			]
		
		Alamofire.request("https://atc.smick.co/order/new", method: .post, parameters: newOrder, encoding: JSONEncoding.default, headers: nil).responseJSON { (resp) in
			print("Sent order and got response JSON:",resp)
			let doneView = UIAlertController(title: "Order Sent", message: "Your order has been sent, and the drone will be on it's way soon!", preferredStyle: .alert)
			let dismissButton = UIAlertAction(title: "Hurry Up", style: .cancel, handler: { (ac) in
				doneView.dismiss(animated: true, completion: {})
				self.tabBarController?.selectedIndex = 2
			})
			doneView.addAction(dismissButton)
			self.present(doneView, animated: true, completion: {
				print("hello")
			})
		}
	}
	
}

