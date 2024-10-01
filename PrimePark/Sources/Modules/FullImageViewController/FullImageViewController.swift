import UIKit

final class FullImageViewController: UIViewController {
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = self
        return scrollView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var closeButton: UIButton = {
        let button = DetailCloseButton()
        button.layer.cornerRadius = 8
        button.addTarget(
            self,
            action: #selector(self.onCloseButtonTap),
            for: .touchUpInside
        )
        return button
    }()

    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = Palette.blackColor

        [self.scrollView, self.closeButton].forEach(view.addSubview)
        self.scrollView.addSubview(self.imageView)

        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.imageView.snp.makeConstraints { make in
            make.height.width.edges.equalToSuperview()
        }

        self.closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = image
    }

    @objc
    private func onCloseButtonTap() {
        self.dismiss(animated: true)
    }
}

extension FullImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
       self.imageView
    }
}
