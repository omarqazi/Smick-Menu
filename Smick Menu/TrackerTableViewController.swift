//
//  TrackerTableViewController.swift
//  
//
//  Created by Omar Qazi on 10/5/18.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import Starscream

class TrackerTableViewController: UITableViewController, WebSocketDelegate, MKMapViewDelegate {
	@IBOutlet var mapView: MKMapView?
	@IBOutlet var orderCell: UITableViewCell?
	@IBOutlet var flightModeCell: UITableViewCell?
	@IBOutlet var altitudeCell: UITableViewCell?
	@IBOutlet var verticalSpeedCell: UITableViewCell?
	@IBOutlet var horizontalSpeedCell: UITableViewCell?
	@IBOutlet var gpsCell: UITableViewCell?
	
	var destinationAnnotation: MKPointAnnotation?
	var aircraftAnnotation: AircraftAnnotation?
	var socket: WebSocket?
	
	var nextOrder: Order = Order()
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		DispatchQueue.global().async {
			self.getNextOrder()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.mapView?.showsUserLocation = true
		self.mapView?.userTrackingMode = .follow
		self.mapView?.delegate = self
	}
	
	func getNextOrder() {
		Alamofire.request("https://atc.smick.co/order/next").responseData { (nextOrderData) in
			if let nod = nextOrderData.data {
				if let nextOrderResponse = try? JSON(data: nod) {
					self.nextOrder.uuid = nextOrderResponse["Id"].stringValue
					self.nextOrder.coordinates.latitude = nextOrderResponse["Latitude"].doubleValue
					self.nextOrder.coordinates.longitude = nextOrderResponse["Longitude"].doubleValue
					self.nextOrder.name = nextOrderResponse["Name"].stringValue
					self.nextOrder.requestedItem = nextOrderResponse["OrderDescription"].stringValue
					self.monitorOrderStatus()
					DispatchQueue.main.async {
						self.displayOrderData()
					}
				}
			} else {
				print("getting next order failed for some reason")
			}
		}
	}
	
	func displayOrderData() {
		self.orderCell?.detailTextLabel?.text = self.nextOrder.name
		if let oldAnnotation = self.destinationAnnotation {
			self.mapView?.removeAnnotation(oldAnnotation)
		}
		
		let destAnnotation = MKPointAnnotation()
		destAnnotation.coordinate = self.nextOrder.coordinates
		destAnnotation.title = "Deliver " + self.nextOrder.requestedItem
		destAnnotation.subtitle = "To " + self.nextOrder.name
		
		self.destinationAnnotation = destAnnotation
		self.mapView?.addAnnotation(destAnnotation)
		
		
		let region = MKCoordinateRegion(center: destAnnotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
		self.mapView?.setRegion(region, animated: true)
	}
	
	func monitorOrderStatus() {
		self.socket = WebSocket(url: self.orderStatusUrl(), protocols: ["smickdrone"])
		self.socket?.delegate = self
		socket?.connect()
	}
	
	func orderStatusUrl() -> URL {
		let urlString = "wss://atc.smick.co/live/\(self.nextOrder.uuid)"
		let url = URL(string: urlString)!
		return url
	}
	
	func websocketDidConnect(socket: WebSocketClient) {
		print("Socket connected")
	}
	
	func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
		print("socket disconnected")
	}
	
	func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
		let flightStatus = JSON(parseJSON: text)
		
		DispatchQueue.main.async {
			if let heading = flightStatus["heading"].float {
				self.updateAircraftHeading(heading: heading)
			}
			
			if let latitude = flightStatus["latitude"].double {
				if let longitude = flightStatus["longitude"].double {
					let newCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
					self.updateAircraftLocation(location: newCoordinates, mapView: self.mapView)
				}
			}
			
			if let flightMode = flightStatus["flight_mode"].string {
				self.flightModeCell?.detailTextLabel?.text = flightMode
			}
			
			if let gps = flightStatus["gps"].string {
				self.gpsCell?.detailTextLabel?.text = "\(gps) Satelites"
			}
			
			if let altitude = flightStatus["altitude"].string {
				self.altitudeCell?.detailTextLabel?.text = altitude
			}
			
			if let hs = flightStatus["horizontal_speed"].string {
				self.horizontalSpeedCell?.detailTextLabel?.text = hs
			}
			
			if let vs = flightStatus["vertical_speed"].string {
				self.verticalSpeedCell?.detailTextLabel?.text = vs
			}
		}
	}
	
	func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
		print("socket received data",data)
	}
	
	func updateAircraftLocation(location: CLLocationCoordinate2D, mapView: MKMapView?) {
		if self.aircraftAnnotation == nil {
			self.aircraftAnnotation = AircraftAnnotation(coordinate: location)
			self.mapView?.addAnnotation(self.aircraftAnnotation!)
			return
		}
 		self.aircraftAnnotation?.coordinate = location
	}
	
	func updateAircraftHeading(heading: Float) {
		if let aa = self.aircraftAnnotation {
			aa.updateHeading(heading: heading)
		}
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is AircraftAnnotation {
			let annotationView = AircraftAnnotationView(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
			let aca = annotation as? AircraftAnnotation
			aca?.annotationView = annotationView
			return annotationView
		}
		
		return nil
	}
	
	
	func sendDispatcherCommand(commandName: String) {
		var dispatcherCommand = [String : String]()
		dispatcherCommand["command"] = "dispatcher"
		dispatcherCommand["method"] = commandName
		if let jsonData = try? JSONSerialization.data(withJSONObject: dispatcherCommand, options: .sortedKeys) {
			let jsonString = String(data: jsonData, encoding: .utf8)!
			if self.socket != nil && self.socket!.isConnected {
				self.socket?.write(string: jsonString)
			}
		}
	}
	
	@IBAction func sendEmergencyStop(sender: AnyObject) {
		self.sendDispatcherCommand(commandName: "stop")
	}
}
