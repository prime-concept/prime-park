//
//  LineLabel.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.05.2021.
//
//swiftlint:disable trailing_whitespace
import UIKit

@IBDesignable
final class LineTextField: UITextField {
    
    private lazy var bottomLine: CALayer = {
        let bottomLine = CALayer()
        bottomLine.backgroundColor = nonActiveColor
        return bottomLine
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: 0x828082)
        label.font = UIFont.primeParkFont(ofSize: 12)
        label.alpha = 0
        return label
    }()
    
    private var activeColor = UIColor(hex: 0xB3987A).cgColor
    private var nonActiveColor = UIColor(hex: 0x828082).withAlphaComponent(0.2).cgColor
    
    @IBInspectable var topPlaceholder: String = "" {
        didSet {
            placeholderLabel.text = topPlaceholder
            placeholderLabel.alpha = 1
        }
    }
    
    func setLeftLabel(label: UILabel) {
        leftViewMode = .always
        leftView = label
    }
    
//    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
//        var textRect = super.leftViewRect(forBounds: bounds)
//        return textRect
//    }
    
//    override func borderRect(forBounds bounds: CGRect) -> CGRect {
//        let border = super.borderRect(forBounds: bounds)
//        let newBorder = CGRect(x: border.origin.x, y: border.origin.y, width: border.width, height: border.height + 30)
//        return newBorder
//    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        font = UIFont.primeParkFont(ofSize: 14)
        borderStyle = .none
        setupBottomLine()
        setupPlaceholderLabel()
        
        addTarget(self, action: #selector(didBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(didEnd), for: .editingDidEnd)
        addTarget(self, action: #selector(changed), for: .editingChanged)
    }
    
    private func setupBottomLine() {
        layer.addSublayer(bottomLine)
        bottomLine.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
    }
    
    private func setupPlaceholderLabel() {
        placeholderLabel.frame = CGRect(x: 0, y: -18, width: bounds.width, height: 18)
        addSubview(placeholderLabel)
    }
    
    @objc
    func didBegin() {
        bottomLine.backgroundColor = activeColor
    }
    
    @objc
    func didEnd() {
        bottomLine.backgroundColor = nonActiveColor
    }
    
    @objc
    func changed() {
        guard topPlaceholder.isEmpty else {
            return
        }
        placeholderLabel.text = placeholder
        if let text = text,
           !text.isEmpty {
            print("show")
            UIView.animate(withDuration: 0.4) {
                self.placeholderLabel.alpha = 1.0
            }
        } else {
            print("hide")
            UIView.animate(withDuration: 0.2) {
                self.placeholderLabel.alpha = 0.0
            }
        }
    }
}
