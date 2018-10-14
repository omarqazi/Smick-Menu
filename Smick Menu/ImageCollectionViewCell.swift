//
//  ImageCollectionViewCell.swift
//  Smick Menu
//
//  Created by Omar Qazi on 10/14/18.
//  Copyright © 2018 Smick Enterprises, Inc. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
	var imageView: UIImageView = UIImageView(image: nil)
	
	func setImage(image: UIImage) {
		let originalImage = self.imageView.image
		self.imageView.image = image
		
		if originalImage == nil {
			self.imageView.frame = self.contentView.frame
			self.imageView.contentMode = .scaleAspectFit
			self.contentView.addSubview(self.imageView)
		}
	}
}
