//
//  LawInfoController.swift
//  PrimePark
//
//  Created by IvanLyuhtikov on 25.12.20.
//

final class LawInfoController: UIViewController {
    private lazy var lawInfoView: LawInfoView = {
        var view = Bundle.main.loadNibNamed("LawInfoView", owner: nil, options: nil)?.first as? LawInfoView ?? LawInfoView()
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
        self.view = self.lawInfoView
        self.lawInfoView.addDelegate(self)
        lawInfoView.commonInit()
    }
}

extension LawInfoController: LawInfoViewProtocol {
}
