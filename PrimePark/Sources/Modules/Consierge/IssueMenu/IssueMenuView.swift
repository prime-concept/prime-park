//
//  IssueMenuView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 04.03.2021.
//
//swiftlint:disable all
import Foundation

protocol IssueMenuViewDelegate: ModalRouterSourceProtocol {
    func didTap(item: HomeItemType)
    func close()
}

final class IssueMenuView: HomeView {
    
    var delegate: IssueMenuViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.makeConstraints()
        changeAccess(LocalAuthService.shared.apartment?.getRole ?? .resident)
    }
    
    private lazy var blurView: UIView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()
    
    private lazy var titleLabel: LocalizableLabel = {
        let label = LocalizableLabel()
        label.font = UIFont.primeParkFont(ofSize: 16, weight: .regular)
        label.text = "Новый запрос"
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Palette.goldColor
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(
            self,
            action: #selector(close),
            for: .touchUpInside
        )
        guard let image = UIImage(named: "Union") else { return button }
        button.setImage(image, for: .normal)
        button.setImage(image, for: .selected)
        return button
    }()
    
    @objc
    func close() {
        delegate?.close()
    }
    
    override func addSubviews() {
        [blurView,
         closeButton,
         collectionView,
         titleLabel
        ].forEach(addSubview)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTap(item: data[indexPath.row])
    }
    
    override func makeConstraints() {
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(83)
            make.size.equalTo(44)
        }
        
        collectionView.snp.makeConstraints { make in
            make.bottom.equalTo(closeButton.snp.top).inset(-21)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(collectionViewHeight)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(collectionView.snp.top).inset(-25)
        }
    }
    
    // MARK: - Access
    
    override func changeAccess(_ role: Role) -> [HomeItemType] {
        switch role {
        case .resident:
            data = [.security, .pass, .parking, .charges, .carwash, .cleaning, .drycleaning, .services, .help, .different]
            return data
        case .cohabitant:
            data = [.security, .pass, .parking, .charges, .carwash, .cleaning, .drycleaning, .services, .help, .different]
            return data
        case .brigadier:
            data = [.security, .pass, .parking, .help, .different]
            return data
        case .guest:
            data = [.security, .help, .different]
            return data
        }
    }
    
}

