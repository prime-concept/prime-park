final class ParkingInfoController: UIViewController {
    private lazy var parkingInfoView: ParkingInfoView = {
        var view = Bundle.main.loadNibNamed("ParkingInfoView", owner: nil, options: nil)?.first as? ParkingInfoView ?? ParkingInfoView()
        return view
    }()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = self.parkingInfoView
        self.parkingInfoView.addDelegate(self)
        parkingInfoView.commonInit()
    }
}

extension ParkingInfoController: ParkingInfoViewProtocol {
}
