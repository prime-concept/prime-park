//
//  ServiceCell.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.03.2021.
//

import UIKit

class ServiceCell: UICollectionViewCell, Reusable {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.backgroundColor = UIColor.black.cgColor
        imageView.layer.opacity = 0.9
        layer.cornerRadius = 18
        clipsToBounds = true
    }
}
