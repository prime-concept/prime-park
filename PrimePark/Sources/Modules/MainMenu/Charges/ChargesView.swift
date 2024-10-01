//
//  ChargesView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 15.03.2021.
//

import Foundation
import SkeletonView

protocol ChargesViewDelegate: AnyObject, PushRouterSourceProtocol, ModalRouterSourceProtocol {
    func presentInfo()
    func openCounter(style: Counter.Measure, description: String)
    func openUDP()
    func makeDeposit()
}

//swiftlint:disable trailing_whitespace multiline_literal_brackets
final class ChargesView: UIView {
    @IBOutlet weak var segmentControl: PrimeSegmentControl!
    @IBOutlet private weak var updTableView: UITableView!
    @IBOutlet private weak var countersTableView: UITableView!
    
    @IBOutlet weak var emptyUdpView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var orderButton: LocalizableButton!
    
    weak var delegate: ChargesViewDelegate?
    
    var isLoadedBalance = false
    
    var balance: String = "1 000 ₽" {
        didSet {
            isLoadedBalance = true
            updTableView.reloadSections([0], with: .fade)
            updTableView.hideSkeleton()
        }
    }
    
    var invoices: [Invoice] = [] {
        didSet {
            updTableView.reloadData()
            updTableView.hideSkeleton()
        }
    }
    
    var counters: [Counter] = [] {
        didSet {
            countersTableView.reloadData()
            countersTableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.3))
        }
    }
    
    func commonInit() {
        updTableView.registerNib(cellClass: ChargesCell.self)
        updTableView.registerNib(headerClass: ChargesHeader.self)
        countersTableView.registerNib(cellClass: CountersCell.self)
        
        updTableView.dataSource = self
        updTableView.delegate = self
        countersTableView.delegate = self
        countersTableView.dataSource = self
        
        updTableView.separatorColor = UIColor.clear
        updTableView.backgroundColor = UIColor(hex: 0x121212)
        var insets = updTableView.contentInset
        insets.bottom += 60
        updTableView.contentInset = insets
        countersTableView.separatorColor = UIColor.clear
        countersTableView.backgroundColor = UIColor(hex: 0x121212)
        countersTableView.contentInset = insets
        
        orderButton.backgroundColor = Palette.goldColor
        
        segmentControl.delegate = self
        updTableView.isHidden = true
        makeSkeletonable()
        self.balanceLabel.text = LocalAuthService.shared.apartment?.number
    }
    
    @IBAction func info(_ sender: Any) {
        delegate?.presentInfo()
    }
    
    @IBAction func deposit(_ sender: Any) {
        delegate?.makeDeposit()
    }
    
    @IBAction func back(_ sender: Any) {
        delegate?.pop()
    }
}

extension ChargesView: SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if skeletonView === updTableView {
            return ChargesCell.defaultReuseIdentifier
        }
        return CountersCell.defaultReuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, identifierForHeaderInSection section: Int) -> ReusableHeaderFooterIdentifier? {
        if skeletonView === updTableView {
            return UPDHeader.defaultReuseIdentifier
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView === updTableView ? invoices.count : counters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === updTableView {
            let cell: ChargesCell = tableView.dequeueReusableCell(for: indexPath)
            cell.data = invoices[indexPath.row]
            return cell
        }
        let cell: CountersCell = tableView.dequeueReusableCell(for: indexPath)
        cell.data = counters[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView === updTableView {
            let header: ChargesHeader = tableView.dequeueReusableHeaderFooterView()
            header.balanceLabel.text = balance
            header.customerReferenceLabel.text = LocalAuthService.shared.apartment?.number
            header.balanceLabel.isHidden = true
            //header.contentView.backgroundColor = UIColor(hex: 0x494949)
            
            if isLoadedBalance {
                header.balanceLabel.hideSkeleton()
                header.balanceLoadingMask.isHidden = true
            } else {
                header.balanceLoadingMask.showAnimatedGradientSkeleton(
                    usingGradient: .init(
                        baseColor: UIColor(hex: 0x353535),
                        secondaryColor: UIColor(hex: 0x212121)
                    ),
                    animation: nil,
                    transition: .crossDissolve(0.25)
                )
            }

            return header
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView === updTableView {
            return UIScreen.main.bounds.height * 0.14
        }
        return 25
    }
}

extension ChargesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === updTableView {
            guard let invoiceStrUrl = invoices[indexPath.row].invoice else {
                ModalRouter(
                    source: delegate,
                    destination: InfoAssembly(title: "Ошибка", subtitle: "ЕПД не содержит дитализированной информации", delegate: nil).make()
                ).route()
                return
            }
            let webView = WebViewController(stringURL: invoiceStrUrl, isNavigationBarHidden: false)
            PushRouter(source: delegate, destination: webView).route()
            return
            //delegate?.openUDP()
            //return
        }
    }
}

extension ChargesView {
    func makeSkeletonable() {
        
        updTableView.rowHeight = 55
        updTableView.estimatedRowHeight = 55
        countersTableView.rowHeight = 84
        countersTableView.estimatedRowHeight = 84
        
        [updTableView, countersTableView].forEach {
            $0?.isSkeletonable = true
            $0?.showAnimatedGradientSkeleton(
                usingGradient: .init(
                    baseColor: UIColor(hex: 0x353535),
                    secondaryColor: UIColor(hex: 0x212121)
                ),
                animation: nil,
                transition: .crossDissolve(0.25)
            )
        }
    }
}

extension ChargesView: PrimeSegmentControlDelegate {
    func didChange(index: Int) {
        emptyUdpView.isHidden = index == 0 ? false : true
    }
}
