//
//  CountersCell.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 16.03.2021.
//

import UIKit

final class CountersCell: UITableViewCell {
    @IBOutlet private weak var contentViewCell: LayerBackgroundView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var imgView: UIImageView!
    @IBOutlet private weak var counterNumber: UILabel!
    
    var data: Counter? {
        didSet {
            if let data = data {
                title.text = localizedWith(data.visualName)
                imgView.image = UIImage(named: data.imageName)
                counterNumber.text = data.separateId()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor(hex: 0x121212)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    fileprivate func fecactorId(id: String?) -> String {
        guard let id = id else {
            return ""
        }
        let components = id.components(separatedBy: "_id")
        return components[0]
    }
}
