import SnapKit
import UIKit

protocol NewsDetailViewProtocol: class {
    func set(viewModel: News?)
}

final class NewsDetailViewController: UIViewController, NewsDetailViewProtocol {
    private static let statusBarHeight = UIApplication.shared.statusBarFrame.height

    private static var headerHeight: CGFloat {
        if Self.statusBarHeight > 20 {
            return CGFloat(250 + Self.statusBarHeight)
        } else {
            return CGFloat(250)
        }
    }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    private lazy var containerView = UIView()

    private lazy var headerView = DetailHeaderView(delegate: self)

    private lazy var infoLabel: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = Palette.blackColor
        textView.textColor = UIColor(hex: 0xcbc9c7)
        textView.font = UIFont.primeParkFont(ofSize: 14)
        textView.dataDetectorTypes = [.link]
        return textView
    }()

    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)

        button.backgroundColor = Palette.goldColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle(Localization.localize("news.copy"), for: .normal)

        button.layer.cornerRadius = 22
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)

        button.addTarget(self, action: #selector(self.onCopyButtonTap), for: .touchUpInside)
        return button
    }()

    private let presenter: NewsDetailPresenterProtocol

    private var viewModel: News?

    init(presenter: NewsDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.backgroundColor = Palette.blackColor

        view.addSubview(self.scrollView)

        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.scrollView.addSubview(self.containerView)

        self.containerView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }

        [self.headerView, self.infoLabel, self.copyButton].forEach(self.containerView.addSubview)

        self.headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Self.headerHeight)
        }
        headerView.clipsToBounds = true

        self.infoLabel.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(15)
        }

        self.copyButton.snp.makeConstraints { make in
            make.top.equalTo(self.infoLabel.snp.bottom)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-44)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.presenter.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func onCopyButtonTap() {
        let title = self.viewModel?.title ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "dd MMMM, HH:mm"
        let date = dateFormatter.string(from: self.viewModel?.createdAt ?? Date())
        let text = self.viewModel?.text ?? ""

        UIPasteboard.general.string = "\(title)\n\(date)\n\(text)"
        UIView.animate(withDuration: 0.5) {
            self.copyButton.backgroundColor = .white
            UIView.animate(withDuration: 0.5) {
                self.copyButton.backgroundColor = Palette.goldColor
            }
        }
    }

    func set(viewModel: News?) {
        self.viewModel = viewModel

        self.headerView.setup(with: viewModel)
        self.infoLabel.text = viewModel?.text
    }
}

extension NewsDetailViewController: DetailHeaderViewDelegate {
    func onCloseButtonTap() {
        self.dismiss(animated: true)
    }

    func onImageTap(image: UIImage) {
        let assembly = FullImageAssembly(image: image)
        let router = ModalRouter(
            source: self,
            destination: assembly.make(),
            modalPresentationStyle: .overFullScreen,
            modalTransitionStyle: .crossDissolve
        )
        router.route()
    }
}
