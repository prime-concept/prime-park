//
//  BlockerController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 22.03.2021.
//

import UIKit

//swiftlint:disable trailing_whitespace
class BlockerController: UIViewController {
    
    private var titleInfo: String
    private var subtitleInfo: String

    @IBOutlet weak var titleLabel: LocalizableLabel!
    @IBOutlet weak var subtitleLabel: LocalizableLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleInfo
        subtitleLabel.text = subtitleInfo
        // Do any additional setup after loading the view.
    }
    
    init(title: String, subtitle: String) {
        titleInfo = title
        subtitleInfo = subtitle
        super.init(nibName: nil, bundle: nil)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
