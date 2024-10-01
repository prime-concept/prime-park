//
//  ServiceListCollection.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.03.2021.
//
//swiftlint:disable all
import UIKit

var mockData = [
	Service(
		imageName: "wifi_image",
		titleName: "services.wifi",
		subtitle: "services.subtitle",
		description: "services.wifi.description",
		serviceTypes: ["services.wifi.type"]
	),
  
	Service(
		imageName: "furniture_primepark_image",
		titleName: "services.primeparkFurniture",
		subtitle: "services.subtitle",
		description: "services.primeparkFurniture.description",
		serviceTypes: ["services.furniture.type"]
	),
	
	Service(
		imageName: "repair_image",
		titleName: "services.repair",
		subtitle: "services.subtitle",
		description: "services.repair.description",
		serviceTypes: ["services.repair.type.first", "services.repair.type.second"]
	),
	
	Service(
		imageName: "gsm_image",
		titleName: "services.gsm",
		subtitle: "services.subtitle",
		description: "services.gsm.description",
		serviceTypes: ["services.gsm.type.first", "services.gsm.type.second"]
	),
	
	Service(
		imageName: "charges_image",
		titleName: "services.panrties",
		subtitle: "services.subtitle",
		description: "services.panrties.description",
		serviceTypes: ["services.panrties.type"]
	),
	
	Service(
		imageName: "furniture_image",
		titleName: "services.furniture",
		subtitle: "services.subtitle",
		description: "services.furniture.description",
		serviceTypes: ["services.furniture.type.first", "services.furniture.type.second"]
	)
]

class ServiceListCollection: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private lazy var statusBarView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.darkColor
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.blackColor
        
        self.collectionView.register(UINib(nibName: ServiceCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: ServiceCell.defaultReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(statusBarView)
        
        statusBarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(UIApplication.shared.statusBarFrame.height)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mockData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ServiceCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.title.text = localizedWith(mockData[indexPath.row].titleName)
        cell.imageView.image = UIImage(named: mockData[indexPath.row].imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width-30, height: 225)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 20)
    }
    

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
			ModalRouter(source: self, destination: WiFiAssembly().make()).route()
        case 1:
			ModalRouter(source: self, destination: BaseServiceAssembly(service: .furniturePrimepark).make()).route()
        case 2:
			ModalRouter(source: self, destination: BaseServiceAssembly(service: .repair).make()).route()
        case 3:
			ModalRouter(source: self, destination: GSMAssembly().make()).route()
        case 4:
			ModalRouter(source: self, destination: BaseServiceAssembly(service: .pantries).make()).route()
        case 5:
			ModalRouter(source: self, destination: BaseServiceAssembly(service: .furniture).make()).route()
        default:
            ModalRouter(source: self, destination: CarWashAssembly(authService: LocalAuthService.shared).make()).route()
        }
    }
}
