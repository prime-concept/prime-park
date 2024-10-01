//
//  CounterCell.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 16.03.2021.
//

import UIKit

final class CounterCell: UITableViewCell {
    @IBOutlet private weak var firstLine: UILabel!
    @IBOutlet private weak var secondLine: UILabel!
    
    var data: (String, String) = ("", "") {
        didSet {
            firstLine.text = data.0
            secondLine.text = data.1
        }
    }
    
    var style: Counter.Measure = .cube() {
        didSet {
            switch style {
            case .tariff:
                firstLine.textColor = UIColor(hex: 0x828082)
                secondLine.textColor = UIColor(hex: 0xFFFFFF)
            default:
                firstLine.textColor = UIColor(hex: 0xFFFFFF)
                secondLine.textColor = UIColor(hex: 0x828082)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
