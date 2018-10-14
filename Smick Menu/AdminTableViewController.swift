//
//  AdminTableViewController.swift
//  Smick Menu
//
//  Created by Omar Qazi on 10/11/18.
//  Copyright © 2018 Smick Enterprises, Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Starscream

class AdminTableViewController: UITableViewController, WebSocketDelegate {
	var socket: WebSocket?
	var orderId: String = ""
	var messages: [[String : JSON]] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
	
	override func viewWillAppear(_ animated: Bool) {
		self.downloadNextOrder()
	}
	
	func downloadNextOrder() {
		Alamofire.request("https://atc.smick.co/order/next").responseJSON { (resp) in
			if let jsonData = resp.data {
				if let responseObject = try? JSON(data: jsonData) {
					if let oid = responseObject["Id"].string {
						self.orderId = oid
						self.connectToSocket()
					}
				}
			}
		}
	}
	
	func connectToSocket() {
		let urlString = "wss://atc.smick.co/live/\(self.orderId)"
		let url = URL(string: urlString)!
		self.socket = WebSocket(url: url, protocols: ["smickdrone"])
		self.socket?.delegate = self
		self.socket?.connect()
	}
	
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		
		var messageTitle  = self.messages[indexPath.row]["MessageTitle"]?.string
		if messageTitle == "" {
			messageTitle = "Status Alert"
		}
		cell.textLabel?.text = messageTitle
		cell.detailTextLabel?.text = self.messages[indexPath.row]["MessageBody"]?.string

        // Configure the cell...

        return cell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120
	}
	
	@IBAction func sendPreconfigCommand(sender: AnyObject) {
		self.sendDispatcherCommand(commandName: "preconfig")
	}
	
	@IBAction func sendConfigCommand(sender: AnyObject) {
		self.sendDispatcherCommand(commandName: "config")
	}
	
	@IBAction func sendStartCommand(sender: AnyObject) {
		self.sendDispatcherCommand(commandName: "start")
	}
	
	@IBAction func sendStopCommand(sender: AnyObject) {
		self.sendDispatcherCommand(commandName: "stop")
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	func websocketDidConnect(socket: WebSocketClient) {
		print("Socket connected")
	}
	
	func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
		print("socket disconnected")
	}
	
	func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
		let flightStatus = JSON(parseJSON: text)
		if flightStatus["MessageButtonTitle"].string != nil {
			if let message = flightStatus.dictionary {
				self.messages.insert(message, at: 0)
				self.tableView.reloadData()
			}
		}
		print("got message",flightStatus)
	}
	
	func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
		print("socket received data",data)
	}

}
