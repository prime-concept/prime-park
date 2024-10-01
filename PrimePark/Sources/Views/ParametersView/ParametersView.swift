//
//  ParametersView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 31.05.2021.
//
// swiftlint:disable trailing_whitespace
import Foundation

protocol ParametersViewDelegate: class {
    var content: [ParametersData] { get }
    var contentCount: Int { get }
    var dynamicSize: CGFloat { get }
    var selectedRow: Int { get }
    
    func select(row: Int)
}

final class ParametersView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var acceptedButton: LocalizableButton!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: ParametersViewDelegate?
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var isButtonHidden = true {
        didSet {
            acceptedButton.isHidden = isButtonHidden
        }
    }
    
    func commonInit(delegate: ParametersViewDelegate) {
        self.delegate = delegate
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(cellClass: ParametersCell.self)
        tableHeightConstraint.constant = delegate.dynamicSize - 150
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}

extension ParametersView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.contentCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ParametersCell = tableView.dequeueReusableCell(for: indexPath)
        cell.data = delegate?.content[indexPath.row]
        return cell
    }
}

extension ParametersView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedRow = delegate?.selectedRow,
           let lastSelectedRow = tableView.cellForRow(at: IndexPath(row: selectedRow, section: 0)) {
            lastSelectedRow.isSelected = false
        }
        
        if let selected = tableView.cellForRow(at: indexPath) {
            selected.isSelected = true
            delegate?.select(row: indexPath.row)
        }
    }
}
