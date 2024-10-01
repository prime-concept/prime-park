//
//  RoundedImageView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 02.06.2021.
//

import Foundation

final class RoundedImageView: RoundedView {
    var imageView = UIImageView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        addSubview(imageView)
        
        layer.borderWidth = 2
        layer.borderColor = Palette.goldColor.cgColor
        layer.cornerRadius = bounds.width / 2
        
        imageView.image = UIImage(named: "user_no_photo")
        imageView.contentMode = .center
        imageView.backgroundColor = Palette.blackColor
        imageView.layer.cornerRadius = (bounds.width / 2) - 1
        imageView.clipsToBounds = true
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
    }
}
