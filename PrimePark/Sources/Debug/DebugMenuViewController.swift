import UIKit

final class DebugMenuViewController: UIViewController {
	private lazy var vStack = UIStackView()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .white
		self.view.addSubview(self.vStack)

		self.vStack.axis = .vertical

		self.vStack.make(.edges, .equal, to: self.view.safeAreaLayoutGuide, [0, 20, 0, -20])

		self.addGrabberView()

		let switchProdView = with(UIView()) { view in
			let label = UILabel()
			label.textColor = .black
			label.font = .systemFont(ofSize: 15)
			label.text = "ПРОД включен: "
			view.addSubview(label)

			let pSwitch = UISwitch()
			pSwitch.isOn = Config.isProdEnabled
			pSwitch.setEventHandler(for: .valueChanged) { [weak self] in
				self?.prodSwitchValueChanged(pSwitch)
			}
			view.addSubview(pSwitch)

			label.make([.leading, .centerY], .equalToSuperview)
			pSwitch.make([.trailing, .centerY], .equalToSuperview)
			view.make(.height, .equal, 44)
		}

		let fcmTokenLabel = UILabel { (label: UILabel) in
			label.textColor = .black
			label.textAlignment = .left
			label.lineBreakMode = .byWordWrapping
			label.numberOfLines = 0
			label.text = "FCM TOKEN (TAP TO SHARE): " + (UserDefaults[string: "FCM_TOKEN"] ?? "???")
			label.isUserInteractionEnabled = true
			label.onTap = {
				guard let text = UserDefaults[string: "FCM_TOKEN"] else {
					return
				}
				Self.shareText(text)
			}
		}

		self.vStack.addArrangedSpacer(22)
		self.vStack.addArrangedSubview(switchProdView)
		self.vStack.addArrangedSpacer(growable: 0)
	}

	@objc
	private func prodSwitchValueChanged(_ prodSwitch: UISwitch) {
		let alert = UIAlertController(title: "Смена параметров",
									  message: "Приложение будет закрыто для применения новых параметров",
									  preferredStyle: .alert)
		alert.addAction(.init(title: "Отмена", style: .cancel, handler: { _ in
			prodSwitch.isOn = !prodSwitch.isOn
		}))
		alert.addAction(.init(title: "Закрыть", style: .destructive) { _ in
			Config.isProdEnabled = prodSwitch.isOn
			LocalAuthService.shared.deleteUser()
			exit(-1)
		})
		self.present(alert, animated: true, completion: nil)
	}

	private func addGrabberView() {
		let grabberView = UIView()
		grabberView.layer.cornerRadius = 2
		grabberView.backgroundColor = .gray
		self.view.addSubview(grabberView)
		grabberView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.size.equalTo(CGSize(width: 36, height: 4))
			make.top.equalToSuperview().offset(10)
		}
	}

	private func makeSwitch(title: String, key: String? = nil, isOn: Bool? = nil, handler: ((UISwitch) -> Void)? = nil) -> UIView {
		let view = UIView()

		let label = UILabel()
		label.text = title
		label.textColor = .black
		label.font = .systemFont(ofSize: 15)
		label.numberOfLines = 2
		label.lineBreakMode = .byWordWrapping

		view.addSubview(label)

		let pSwitch = UISwitch()
		if let key = key {
			pSwitch.isOn = UserDefaults[bool: key]
			pSwitch.setEventHandler(for: .valueChanged) {
				UserDefaults[bool: key] = pSwitch.isOn
				handler?(pSwitch)
			}
		} else if let isOn = isOn {
			pSwitch.isOn = isOn
			pSwitch.setEventHandler(for: .valueChanged) {
				handler?(pSwitch)
			}
		}

		view.addSubview(pSwitch)

		label.make([.leading, .centerY], .equalToSuperview)
		pSwitch.make([.trailing, .centerY], .equalToSuperview, [-5, 0])
		view.make(.height, .equal, 44)

		return view
	}

	private func makeTextField(
		title: String,
		key: String? = nil,
		keyboardType: UIKeyboardType = .default,
		handler: ((UITextField) -> Void)? = nil
	) -> UIView {
		let view = UIView()

		let label = UILabel()
		label.text = title
		label.textColor = .black
		label.font = .systemFont(ofSize: 15)
		label.numberOfLines = 2
		label.lineBreakMode = .byWordWrapping

		view.addSubview(label)

		let textField = UITextField()
		if let key = key {
			textField.text = UserDefaults[string: key]
		}

		textField.setEventHandler(for: .editingChanged) {
			if let handler = handler {
				handler(textField)
			} else if let key = key {
				UserDefaults[string: key] = textField.text
			}
		}

		textField.keyboardType = keyboardType
		textField.layer.borderWidth = 1
		textField.layer.cornerRadius = 2
		textField.layer.borderColor = UIColor.red.cgColor
		textField.textColor = .black

		textField.textAlignment = .center

		view.addSubview(textField)

		label.make([.leading, .centerY], .equalToSuperview)

		textField.make([.trailing, .centerY, .height], .equalToSuperview, [-5, 0, -12])
		textField.make(.leading, .equal, to: .trailing, of: label, +10)
		textField.make(.width, .greaterThanOrEqual, 44)

		view.make(.height, .equal, 44)

		return view
	}
}

extension DebugMenuViewController {
	static func shareText(_ text: String, completion: (() -> Void)? = nil) {
		onMain {
			let activityItems = [text]

			let activity = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
			activity.excludedActivityTypes = [.assignToContact, .postToTwitter]
			activity.completionWithItemsHandler = { _, _, _, _ in
				completion?()
			}

			let rootVC = UIApplication.shared.keyWindow?
				.rootViewController?
				.topmostPresentedOrSelf
			rootVC?.present(activity, animated: true)
		}
	}
}

private class LogViewer: UIViewController {
	private(set) lazy var textView = UITextView()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .white

		self.view.addSubview(self.textView)

		if #available(iOS 13.0, *) {
			self.textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
		}

		self.textView.isEditable = false
		self.textView.make(.edges, .equal, to: self.view.safeAreaLayoutGuide, [0, 10, 0, -10])
	}

	func scrollToBottom() {
		let range = NSMakeRange(self.textView.text.lengthOfBytes(using: .utf8), 0);
		self.textView.scrollRangeToVisible(range);
	}
}
