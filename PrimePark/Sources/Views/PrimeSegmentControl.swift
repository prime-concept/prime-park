//
//  PrimeSegmentControl.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.06.2021.
//
// swiftlint:disable trailing_whitespace
import Foundation

protocol PrimeSegmentControlDelegate: class {
    func didChange(index: Int)
}

@IBDesignable
final class PrimeSegmentControl: LayerBackgroundView {
    private var buttons = [LocalizableButton]()
    
    private lazy var selector: LayerBackgroundView = {
        var sel = LayerBackgroundView()
        sel.frame = .init(x: 3, y: 4, width: itemWidth, height: frame.height - 7)
        sel.isBottomShadow = false
        sel.layer.cornerRadius = sel.bounds.height / 2
        sel.backgroundColor = UIColor(hex: 0x363636)
        return sel
    }()
    
    weak var delegate: PrimeSegmentControlDelegate?
    
    var textColor = UIColor(hex: 0x828082)
    var selectTextColor = UIColor.white
    
    private var outermostSpace: CGFloat {
        return selectedSegmentIndex == 0 ? 3 : -3
    }
    
    private var itemWidth: CGFloat {
        return bounds.size.width / CGFloat(buttons.count)
    }
    
    @IBInspectable var segmentTitles: String = "" {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var selectedSegmentIndex = 0 {
        didSet {
            guard selectedSegmentIndex < buttons.count else { return }
            changeSelection(tag: selectedSegmentIndex)
            if oldValue != selectedSegmentIndex {
                delegate?.didChange(index: selectedSegmentIndex)
            }
        }
    }
    
    @IBInspectable var isBasicStyle: Bool = false {
        didSet {
            isBasicStyle ? makeBasicStyle() : ()
        }
    }
    
    func updateView() {
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        
        backgroundColor = UIColor(hex: 0x121212)
        //clipsToBounds = true
        
        let titles = self.segmentTitles.components(separatedBy: ",")
        for (i, title) in titles.enumerated() {
            let button = LocalizableButton(type: .system)
            button.tag = i
            let font = UIFont.primeParkFont(ofSize: 12)
            button.titleLabel?.font = font
            button.localizedKey = title
            button.setTitleColor(UIColor(hex: 0x828082), for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(selectedButton:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        guard let first = buttons[safe: selectedSegmentIndex] else { return }
        first.setTitleColor(selectTextColor, for: .normal)
        first.titleLabel?.font = UIFont.boldPrimeParkFont(ofSize: 12)
        
        addSubview(selector)

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc
    func buttonTapped(selectedButton: UIButton) {
        selectedSegmentIndex = selectedButton.tag
        changeSelection(tag: selectedButton.tag)
    }
    
    private func changeSelection(tag: Int) {
        let selectedButton = buttons[tag]
        
        for button in buttons {
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.font = UIFont.primeParkFont(ofSize: 12)
        }
        selectedButton.setTitleColor(selectTextColor, for: .normal)
        selectedButton.titleLabel?.font = UIFont.boldPrimeParkFont(ofSize: 12)
        
        UIView.animate(withDuration: 0.25) {
            self.selector.frame.origin.x = CGFloat(selectedButton.tag) * self.itemWidth + self.outermostSpace
        }
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = bounds.height / 2
        
        selector.frame = CGRect(
            x: selector.frame.origin.x,
            y: selector.frame.origin.y,
            width: bounds.width / CGFloat(buttons.count),
            height: selector.bounds.height
        )
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .init(x: 15, y: 0, width: UIScreen.main.bounds.width - 30, height: 37))
    }
    
    func makeBasicStyle() {
        clearShadow()
        selector.frame.origin.y = 3
        selector.frame.size.height = frame.height - 6
    }
    
    private func clearShadow() {
        var allViews = subviews
        allViews.append(self)
        
        allViews.forEach {
            $0.layer.shadowColor = nil
            $0.layer.shadowOffset = .zero
            $0.layer.shadowRadius = 0
            $0.layer.shadowOpacity = 0
        }
    }
}
