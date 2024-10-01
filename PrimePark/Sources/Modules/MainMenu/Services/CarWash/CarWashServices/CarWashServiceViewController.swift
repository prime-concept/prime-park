import UIKit
import SnapKit

final class CarWashServiceViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.text = localizedWith("carWash.chooseType.title")
        label.font = UIFont.primeParkFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.allowsMultipleSelection = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(
            CarWashServiceTableViewCell.self,
            forCellReuseIdentifier: CarWashServiceTableViewCell.defaultReuseIdentifier
        )
        return tableView
    }()
    private lazy var separatorView: UIView = {
        let view = OnePixelHeightView()
        view.backgroundColor = .gray
        view.alpha = 0.2
        return view
    }()
    
    private var services: [ServicesViewModel] = []
    var choosenClosure: ((ServicesViewModel, Int) -> Void)

    init(services: [ServicesViewModel],
         choosenClosure: @escaping ((ServicesViewModel, Int) -> Void)) {
        self.services = services
        self.choosenClosure = choosenClosure
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.setupView()
        self.makeConstraints()
        self.tableView.reloadData()
    }

    private func setupView() {
        self.view.backgroundColor = Palette.darkColor
        [
            self.titleLabel,
            self.separatorView,
            self.tableView
        ].forEach(self.view.addSubview)
    }

    private func makeConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(27)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
        }
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.separatorView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension CarWashServiceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.services.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CarWashServiceTableViewCell.defaultReuseIdentifier,
            for: indexPath
        ) as? CarWashServiceTableViewCell else {
            return UITableViewCell()
        }
        cell.setup(with: self.services[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.services[indexPath.row].isSelected = true
        if let selected = tableView.cellForRow(at: indexPath) {
            selected.isSelected = true
        }
        self.choosenClosure(self.services[indexPath.row], indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.services[indexPath.row].isSelected = false
        if let selected = tableView.cellForRow(at: indexPath) {
            selected.isSelected = false
        }
    }
}
