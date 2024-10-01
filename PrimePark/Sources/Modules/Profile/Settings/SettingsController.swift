import UIKit
import MessageUI
import Foundation

protocol SettingsControllerProtocol: MainScreenRouterProtocol {
}

final class SettingsController: UIViewController {
    private lazy var settingsView: SettingsView = {
        let view = Bundle.main.loadNibNamed("SettingsView", owner: nil, options: nil)?.first as? SettingsView ?? SettingsView()
        return view
    }()

    private let presenter: SettingsPresenterProtocol
    private var infoView: InfoView?

    init(presenter: SettingsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.settingsView
        settingsView.setDelegate(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupProductLabel()
    }
    
    private func setupProductLabel() {
        self.settingsView.productVersionLabel.textColor = Palette.goldColor
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else { return }
        self.settingsView.productVersionLabel.text = "Version: \(version), build: \(build)"
    }
    
    private func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["it_docs@c-and-u.co"])
        composer.setSubject(Localization.localize("profile.delete.mail.subject") + self.presenter.getUserPhone())
        composer.setMessageBody((Localization.localize("profile.delete.mail.text") + self.presenter.getUserInfo()), isHTML: true)
        present(composer, animated: true)
    }
}

extension SettingsController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}

extension SettingsController: SettingsViewDelegate {
    func changeLanguage() {
        self.presenter.changeLanguage()
    }

    func logout() {
        let alert = UIAlertController(
            title: Localization.localize("profile.logout.title"),
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: Localization.localize("alert.button.yes"),
            style: .default,
            handler: { _ in
                self.presenter.logout()
            }))
        alert.addAction(UIAlertAction(
            title: Localization.localize("alert.button.no"),
            style: .cancel,
            handler: nil
        ))
        //alert.view.layer.cornerRadius = 22
        alert.view.tintColor = .white

        present(module: alert)
    }

    func back() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func deleteUser() {
        let alert = UIAlertController(
            title: Localization.localize("profile.delete.title"),
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: Localization.localize("alert.button.delete"),
            style: .default,
            handler: { _ in
                self.showMailComposer()
            }))
        alert.addAction(UIAlertAction(
            title: Localization.localize("alert.button.cancel"),
            style: .cancel,
            handler: nil
        ))
        alert.view.tintColor = .white

        present(module: alert)
    }
}

extension SettingsController: SettingsControllerProtocol {}

extension SettingsController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
