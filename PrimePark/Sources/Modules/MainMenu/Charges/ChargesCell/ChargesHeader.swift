//
//  ChargesHeader.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 15.03.2021.
//

import UIKit

class ChargesHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var customerReferenceLabel: UILabel!
    @IBOutlet weak var balanceLoadingMask: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
