//
//  ValetModalAbonementView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 19.05.2021.
//

import Foundation

protocol ValetModalAbonementViewDelegate: AnyObject {
    func makeOrder(with tariff: ValetAbonementTariff)
}

final class ValetModalAbonementView: UIView {
    
    @IBOutlet var buttons: [LocalizableButton]!
    @IBOutlet weak var orderButton: LocalizableButton!
    
    private let tariffs = [ValetAbonementTariff.oneMonth, .twoMonth, .sixMonth]
    
    weak var delegate: ValetModalAbonementViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttons.enumerated().forEach {
            
            $0.element.setTitleColor(.white, for: .selected)
            $0.element.layer.borderWidth = 1
            $0.element.layer.borderColor = UIColor(hex: 0x4F4F4F).cgColor
            $0.element.localizedKey = tariffs[$0.offset].rawValue
        }
    }
    
    @IBAction func chooseTariff(_ button: LocalizableButton) {
        buttons.forEach {
            $0.isSelected = false
            $0.backgroundColor = UIColor(hex: 0x363636)
            $0.layer.borderWidth = 1
        }
        button.isSelected = true
        button.backgroundColor = UIColor(hex: 0xAF987E)
        button.layer.borderWidth = 0
    }
    
    @IBAction func order(_ sender: Any) {
        let tariff = buttons.first { $0.isSelected }?.localizedKey ?? "none"
        delegate?.makeOrder(with: ValetAbonementTariff(rawValue: tariff) ?? .oneMonth)
    }
    
    func startLoading() {
        orderButton.startButtonLoadingAnimation()
    }
    
    func stopLoading() {
        orderButton.endButtonLoadingAnimation(defaultTitle: "Заказать")
    }
}
