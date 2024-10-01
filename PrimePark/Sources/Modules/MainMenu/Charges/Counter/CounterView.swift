//
//  CounterView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 16.03.2021.
//
//swiftlint:disable trailing_whitespace

import SkeletonView

protocol CounterViewDelegate: class {
    func tapBack()
}

final class CounterView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: LocalizableLabel!
    
    var title: String = "" {
        didSet {
            titleLabel.localizedKey = title
        }
    }
    
    weak var delegate: CounterViewDelegate?
    
    private var counters: [Counter] = []
    
    private var groupedCounters: [String: [Counter]] = [:]
    private var keys: [String] = []
    
    var style: Counter.Measure = .cube() {
        didSet {
            tableView.reloadData()
        }
    }
    
    func commonInit() {
        tableView.registerNib(cellClass: CounterCell.self)
        tableView.registerNib(headerClass: CounterHeaderView.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.clear
        tableView.backgroundColor = UIColor(hex: 0x121212)
        
        var insets = tableView.contentInset
        insets.bottom += 60
        tableView.contentInset = insets
        
        makeSkeletonable()
    }
    
    func setCountersHistory(history: [Counter]) {
        counters = history
        groupedCounters = history.makeGroupedForTariff()
        keys = [String](groupedCounters.keys).sorted()
        tableView.reloadData()
        tableView.hideSkeleton()
    }
    
    @IBAction func back(_ sender: Any) {
        delegate?.tapBack()
    }
}

extension CounterView: SkeletonTableViewDataSource, UITableViewDelegate {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return CounterCell.defaultReuseIdentifier
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        style == .tariff(.electricity) ? keys.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if style == .tariff(.electricity) {
            if section == 0 {
                return 0
            }
            return groupedCounters[keys[section - 1]]?.count ?? 0
        }
        return counters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CounterCell = tableView.dequeueReusableCell(for: indexPath)
        var data: Counter
        if style == .tariff(.electricity) {
            data = groupedCounters[keys[indexPath.section - 1]]?[indexPath.row] ?? Counter(values: 101)
            cell.style = .tariff()
        } else {
            data = counters[indexPath.row]
        }
        cell.data = (data.title, String(data.valuesDisplayable))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header: CounterHeaderView = tableView.dequeueReusableHeaderFooterView()

            guard let firstCounter = counters.first else {
                header.counterNumberLabel.text = ""
                return header
            }
            header.counterNumberLabel.text = firstCounter.separateId()

            return header
        }
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x252525)
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)
        label.text = keys[section - 1]
        label.frame = CGRect(x: 15, y: 0, width: UIScreen.main.bounds.width, height: 28)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60
        }
        return 28
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

extension CounterView {
    func makeSkeletonable() {
        
        tableView.rowHeight = 55
        tableView.estimatedRowHeight = 55
        
        tableView.isSkeletonable = true
        tableView.showAnimatedGradientSkeleton(
                usingGradient: .init(
                    baseColor: UIColor(hex: 0x353535),
                    secondaryColor: UIColor(hex: 0x212121)
                ),
                animation: nil,
                transition: .crossDissolve(0.25)
            )
    }
}
