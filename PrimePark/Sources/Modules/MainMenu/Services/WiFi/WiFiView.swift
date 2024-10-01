//
//  WiFiView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.03.2021.
//
//swiftlint:disable all
final class WiFiView: BaseService {
    
    lazy var dateComponent: DateComponent = {
        let component = DateComponent(frame: .zero)
        return component
    }()
    
    lazy var timeComponent: TimeComponent = {
        let component = TimeComponent(frame: .zero)
        return component
    }()
    
    override init(
        service: Service.ServiceType,
        delegate: BaseServiceDelegate? = nil
    ) {
        super.init(service: service, delegate: delegate)
//        dateComponent.presenterController = delegate
//        timeComponent.presenterController = delegate
//        addSubviews()
//        makeConstraints()
    }
    override func layoutSubviews() {
//        verticalSpaceConstraint.constant = dateComponent.bounds.height + timeComponent.bounds.height + 30
    }
}



extension WiFiView: Designable {
    func addSubviews() {
        [dateComponent,
         timeComponent
        ].forEach {
            componentContentView.addSubview($0)
        }
    }
    func makeConstraints() {
        dateComponent.snp.makeConstraints { make in
            make.top.equalTo(serviceType.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
        }
        timeComponent.snp.makeConstraints { make in
            make.top.equalTo(dateComponent.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
        }
    }
}
