//
//  PrimeAlertView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 09.06.2021.
//
// swiftlint:disable trailing_whitespace
import Foundation

protocol PrimeAlertViewDelegate: AnyObject {
    func buttonTapped(tag: Int)
}

final class PrimeAlertView: UIView {
    enum PrimeAlertType {
        case info(String)
        case adjustable(String, String)
    }
    
    weak var delegate: PrimeAlertViewDelegate?
    private var type: PrimeAlertType

    private let titleColor = UIColor.white
    private let subtitleColor = UIColor.white.withAlphaComponent(0.5)
    
    init(
        delegate: PrimeAlertViewDelegate?,
        title: String,
        subtitle: String?,
        type: PrimeAlertType = .info("Ok")
    ) {
        self.delegate = delegate
        self.type = type
        super.init(frame: .zero)
        
        constructAlert(
            title: title,
            subtitle: subtitle,
            type: type
        )

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }
    
    func constructAlert(
        title: String,
        subtitle: String?,
        type: PrimeAlertType
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        switch type {
        case .adjustable(let first, let second):
            for (i, title) in [first, second].enumerated() {
                let button = makeButton(title: title)
                button.tag = i
                stackView.addArrangedSubview(button)
            }
        case .info(let first):
            let button = makeButton(title: first)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc
    private func onButtonTap(button: UIButton) {
        self.delegate?.buttonTapped(tag: button.tag)
    }

    public func addText(title: String, subtitle: String) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }

    private lazy var roundedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x383738)
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 17)
        label.textColor = self.titleColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 14)
        label.textColor = self.subtitleColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var divideView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(hex: 0x545458).withAlphaComponent(0.65)
        return view
    }()
    
    private lazy var divideBottomButtons: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x545458).withAlphaComponent(0.65)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()

    private func makeButton(title: String) -> UIButton {
        let button = UIButton(type: .system)

        button.setTitle(localizedWith(title), for: .normal)
        button.titleLabel?.font = UIFont.primeParkFont(ofSize: 17)

        button.backgroundColor = UIColor.clear
        button.setTitleColor(Palette.goldColor, for: .normal)

        button.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)

        return button
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        type = .info("Ok")
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }
}

extension PrimeAlertView: Designable {
    func setupView() {
        self.backgroundColor = Palette.blackColor
        //self.alpha = 0.85
        self.subtitleLabel.setContentHuggingPriority(.init(rawValue: 252), for: .vertical)
        self.titleLabel.setContentHuggingPriority(.init(rawValue: 251), for: .vertical)
    }
    
    func addSubviews() {
        self.addSubview(self.roundedView)
        [
            self.titleLabel,
            self.subtitleLabel,
            self.divideView,
            self.stackView
        ].forEach(self.roundedView.addSubview)
        
        switch type {
        case .adjustable:
            self.roundedView.addSubview(divideBottomButtons)
        default:
            print("")
        }
    }
    
    func makeConstraints() {
        self.roundedView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.divideView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            roundedView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            roundedView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            roundedView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),

            titleLabel.topAnchor.constraint(equalTo: roundedView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: 16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -16),

            divideView.heightAnchor.constraint(equalToConstant: 1),
            divideView.widthAnchor.constraint(equalTo: roundedView.widthAnchor),
            divideView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            divideView.bottomAnchor.constraint(equalTo: stackView.topAnchor),

            stackView.heightAnchor.constraint(equalToConstant: 44),
            stackView.widthAnchor.constraint(equalTo: roundedView.widthAnchor),
            stackView.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor)
        ])
        
        switch type {
        case .adjustable:
            divideBottomButtons.translatesAutoresizingMaskIntoConstraints = false
            
            divideBottomButtons.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: UIScreen.main.bounds.width * 0.7 / 2).isActive = true
            divideBottomButtons.heightAnchor.constraint(equalToConstant: 44).isActive = true
            divideBottomButtons.widthAnchor.constraint(equalToConstant: 1).isActive = true
            divideBottomButtons.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
            divideBottomButtons.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        default:
            print("")
        }
    }
}
