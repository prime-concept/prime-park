//
//  ValetDayCell.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 05.05.2021.
//
// swiftlint:disable trailing_whitespace multiline_literal_brackets force_unwrapping
import UIKit

class ValetDayCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var backgroundContentView: RoundedView!
    
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isRunOut = false
    }
    
    var isRunOut: Bool = false {
        didSet {
            isRunOut ? makeRunOut() : (isSelected ? makeSelected() : makeUnselected())
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard !isRunOut else { return }
            isSelected ? makeSelected() : makeUnselected()
        }
    }
    
    var data: ValetTimeModel? {
        didSet {
            dayOfWeekLabel.text = data?.dayOfWeek
            dayLabel.text = data?.day
            monthLabel.text = data?.month
            isRunOut = data?.isRunOut == nil ? false : data!.isRunOut
        }
    }
}

extension ValetDayCell {
    func makeSelected() {
        isUserInteractionEnabled = true
        backgroundContentView.backgroundColor = UIColor(hex: 0xB4987A)
        [dayOfWeekLabel,
         dayLabel,
         monthLabel
        ].forEach { $0?.textColor = .white }
    }
    
    func makeUnselected() {
        isUserInteractionEnabled = true
        backgroundContentView.backgroundColor = UIColor(hex: 0x363636)
        [dayOfWeekLabel,
         dayLabel,
         monthLabel
        ].forEach { $0?.textColor = UIColor(hex: 0x868486) }
    }
    
    func makeRunOut() {
        isUserInteractionEnabled = false
        [dayOfWeekLabel,
         dayLabel,
         monthLabel
        ].forEach { $0?.textColor = UIColor(hex: 0x474747) }
    }
}
