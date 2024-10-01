//
//  UPDView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 19.03.2021.
//

import UIKit
//swiftlint:disable trailing_whitespace
final class UPDView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    
    func commonInit() {
        tableView.registerNib(cellClass: CounterCell.self)
        tableView.registerNib(headerClass: UPDHeader.self)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = UIColor(hex: 0x121212)
        tableView.separatorColor = UIColor.clear
        var insets = tableView.contentInset
        insets.bottom += 60
        tableView.contentInset = insets
    }
}

extension UPDView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CounterCell = tableView.dequeueReusableCell(for: indexPath)
        cell.style = .tariff()
        cell.data = ("Горячая вода", "3 343 ₽")
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: UPDHeader.defaultReuseIdentifier) {
                print("good")
                return header
            }
        }
        // Default section
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x252525)
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)
        label.text = "Коммунальные"
        label.frame = CGRect(x: 15, y: 0, width: UIScreen.main.bounds.width, height: 28)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return UIScreen.main.bounds.height * 0.12
        }
        return 28
    }
}
