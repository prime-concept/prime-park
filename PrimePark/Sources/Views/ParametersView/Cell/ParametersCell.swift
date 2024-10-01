//
//  ParametersCell.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 31.05.2021.
//
// swiftlint:disable trailing_whitespace
import UIKit

class ParametersCell: UITableViewCell {
    private static let defaultColor = Palette.darkLightColor
    private static let selectedColor = UIColor.white
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var checkMarkImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var data: ParametersData? {
        didSet {
            nameLabel.text = data?.name
            isSelected = (data?.isSelected ?? false)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    func updateAppearance() {
        nameLabel.textColor = isSelected ? Self.selectedColor : Self.defaultColor
        checkMarkImgView.isHidden = !self.isSelected
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
