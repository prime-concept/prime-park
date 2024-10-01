//
//  UPDController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 19.03.2021.
//

import UIKit

class UPDController: UIViewController {
    private lazy var updView: UPDView = {
        return Bundle.main.loadNibNamed("UPDView", owner: nil, options: nil)?.first as? UPDView ?? UPDView()
    }()
    
    override func loadView() {
        view = updView
        updView.commonInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
