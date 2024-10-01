import UIKit

final class SplashViewController: UIViewController {
    private lazy var backgroundView = PrimeParkBackgroundView()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func loadView() {
        let view = UIView()

        [self.backgroundView, self.logoImageView].forEach(view.addSubview)

        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.logoImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 165, height: 95))
        }

        self.view = view
    }
}
