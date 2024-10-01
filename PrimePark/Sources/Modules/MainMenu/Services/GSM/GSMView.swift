//
//  GSMView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.03.2021.
//
//swiftlint:disable all
protocol GSMViewDelegate: ModalRouterSourceProtocol {
}

final class GSMView: BaseService {
    
    weak var delegate: GSMViewDelegate?
    
    lazy var dateComponent: DateComponent = {
        let component = DateComponent(frame: .zero)
        return component
    }()
    
    override init(
        service: Service.ServiceType,
        delegate: BaseServiceDelegate? = nil
    ) {
        super.init(service: service, delegate: delegate)
        dateComponent.presenterController = delegate
        addSubviews()
        makeConstraints()
    }
    
    override func layoutSubviews() {
        verticalSpaceConstraint.constant = dateComponent.bounds.height + 15
    }
}

extension GSMView: Designable {
    func addSubviews() {
        componentContentView.addSubview(dateComponent)
    }
    func makeConstraints() {
        dateComponent.snp.makeConstraints { make in
            make.top.equalTo(serviceType.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
        }
    }
}
