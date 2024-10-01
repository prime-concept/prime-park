//
//  ChargesCell.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 15.03.2021.
//

import UIKit

class ChargesCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rublesLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var data: Invoice? {
        didSet {
            dateLabel.text = data?.strMonth
            makeFullStyle()
            rublesLabel.text = data?.strCurrency
        }
    }
    
    func makeUnpaid() {
        arrowImageView.image = UIImage(named: "arrow_red")
        rublesLabel.textColor = UIColor(hex: 0xCC2A21)
    }
    func makePaid() {
        arrowImageView.image = UIImage(named: "arrow_green")
        rublesLabel.textColor = UIColor(hex: 0xFFFFFF)
    }
}

extension ChargesCell {
    //swiftlint:disable colon
    func makeFullStyle() {
        let attributedStr = NSMutableAttributedString(
            string: localizedWith("charges.upd.title") + "/",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(hex: 0x828282)]
        )
        let attr = NSMutableAttributedString(
            string: dateLabel.text ?? "her",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(hex: 0xFFFFFF)]
        )
        attributedStr.append(attr)
        print(attributedStr)
        dateLabel.attributedText = attributedStr
    }
}
