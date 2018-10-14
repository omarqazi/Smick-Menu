//
//  MenuCollectionViewController.swift
//  Smick Menu
//
//  Created by Omar Qazi on 10/13/18.
//  Copyright © 2018 Smick Enterprises, Inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MenuCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		self.collectionView.allowsMultipleSelection = true
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
		
        cell.contentView.backgroundColor = UIColor.purple
		let imageView = UIImageView(image: UIImage(named: "Coca-Cola"))
		imageView.frame = cell.contentView.frame
		imageView.contentMode = .scaleAspectFill
		cell.contentView.addSubview(imageView)
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: 200, height: 100)
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MenuHeaderView", for: indexPath)
	}

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
	
	override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func addPurpleBorderToCell(cell: UICollectionViewCell, withAlpha: CGFloat) {
		let purpleColor = UIColor(red: (101.0/255.0), green: (40.0/255.0), blue: (190.0/255.0), alpha: withAlpha)
		cell.contentView.layer.borderWidth = 4.0
		cell.contentView.layer.cornerRadius = 10.0
		cell.contentView.layer.borderColor = purpleColor.cgColor
	}
	
	func applyBorderToCollectionView(collectionView: UICollectionView, atIndexPath: IndexPath, withAlpha: CGFloat,animationDuration: TimeInterval) {
		if let cell = collectionView.cellForItem(at: atIndexPath) {
			UIView.transition(with: cell.contentView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
				self.addPurpleBorderToCell(cell: cell, withAlpha: withAlpha)
			}, completion: nil)
		}
	}
	
	func unapplyBorderToCollectionView(collectionView: UICollectionView, atIndexPath: IndexPath,animationDuration: TimeInterval) {
		if let cell = collectionView.cellForItem(at: atIndexPath) {
			UIView.transition(with: cell.contentView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
				cell.contentView.layer.borderWidth = 0.0
				cell.contentView.layer.borderColor = UIColor.white.cgColor
			}, completion: nil)
		}
	}
	
	func updateCartBadgeCount() {
		if let allSelectedPaths = collectionView.indexPathsForSelectedItems {
			let totalSelectedItems = allSelectedPaths.count
			if let cartItems = self.tabBarController?.tabBar.items {
				if cartItems.count > 1 {
					let tabItem = cartItems[1]
					if totalSelectedItems > 0 {
						tabItem.badgeValue = totalSelectedItems.description
					} else {
						tabItem.badgeValue = nil
					}
					
				}
			}
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.applyBorderToCollectionView(collectionView: collectionView, atIndexPath: indexPath, withAlpha: 1.0, animationDuration: 0.3)
		self.updateCartBadgeCount()
	}
	
	override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		self.unapplyBorderToCollectionView(collectionView: collectionView, atIndexPath: indexPath, animationDuration: 0.3)
		self.updateCartBadgeCount()
	}
	
	override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		self.applyBorderToCollectionView(collectionView: collectionView, atIndexPath: indexPath, withAlpha: 0.7,animationDuration: 0.1)
	}
	
	override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		self.unapplyBorderToCollectionView(collectionView: collectionView, atIndexPath: indexPath, animationDuration: 0.1)
	}

    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
		print("asked to perfrom action at index path",indexPath)
    }
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 160, height: 200)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 30.0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 15.0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
	}
	
	override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
		if let headerView = view as? MenuHeaderCollectionReusableView {
			var sectionTitle = "Weed"
			if indexPath.section == 0 {
				sectionTitle = "Drinks"
			} else if indexPath.section == 1 {
				sectionTitle = "Food"
			}
			headerView.titleLabel?.text = sectionTitle
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
			if selectedIndexPaths.contains(indexPath) {
				self.addPurpleBorderToCell(cell: cell, withAlpha: 1.0)
			}
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		cell.contentView.layer.borderColor = UIColor.white.cgColor
	}
	
	@IBAction func donePickingItems(sender: AnyObject) {
		self.tabBarController?.selectedIndex = 1
		if let tabViewControllers = self.tabBarController?.viewControllers {
			print("got view controllers")
			if let orderNav = tabViewControllers[1] as? UINavigationController {
				if let orderVC = orderNav.viewControllers[0] as? OrderViewController {
					print("got order view controller")
					orderVC.orderSummary = "Coca Cola"
				} else {
					print("what i got was",orderNav.viewControllers[0])
				}
			}
		}
	}
}
