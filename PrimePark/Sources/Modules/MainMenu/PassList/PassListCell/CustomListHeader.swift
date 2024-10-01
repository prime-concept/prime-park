//
//  PassListHeader.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 27.02.2021.
//
//swiftlint:disable all
import UIKit

final class CustomListHeader: UITableViewHeaderFooterView {
    let title = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    func configureContents() {
        title.textColor = UIColor.white
        title.font = UIFont.primeParkFont(ofSize: 20, weight: .medium)
        title.isSkeletonable = true
        
        title.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(title)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
