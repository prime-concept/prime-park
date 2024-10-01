import UIKit
//swiftlint:disable trailing_whitespace
final class PrimeParkNavigationController: UINavigationController {
    
    private var statusBarView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.darkColor
        return view
    }()
    
    private var isStatusBarEnabled: Bool = false
    
    @objc var closeCompletion: (() -> Void)?
    
    init(
		rootViewController: UIViewController,
		isStatusBarEnabled: Bool = false,
		statusBarColor: UIColor = Palette.darkColor
	) {
        self.isStatusBarEnabled = isStatusBarEnabled
		statusBarView.backgroundColor = statusBarColor
        super.init(rootViewController: rootViewController)
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isStatusBarEnabled {
            view.addSubview(statusBarView)
            
            statusBarView.snp.makeConstraints { make in
                make.leading.top.trailing.equalToSuperview()
                make.height.equalTo(UIApplication.shared.statusBarFrame.height)
            }
        }
    }
}
