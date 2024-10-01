//
//  ValetTimePickerController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 06.05.2021.
//

import UIKit

class ValetTimePickerController: PannableViewController {
    private lazy var valetTimePickerView: ValetTimePickerView = {
        return Bundle.main.loadNibNamed("ValetTimePickerView", owner: nil, options: nil)?.first as? ValetTimePickerView ?? ValetTimePickerView()
    }()
    
    var presenterController: ValetTimeHolder?
    
    let panel = PanelTransition()
    
    override func loadView() {
        view = valetTimePickerView
        valetTimePickerView.commonInit(delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        panel.isPresentedDismiss = false
        panel.currentPresentation = .valetTimePicker
    }
}

extension ValetTimePickerController: ValetTimePickerViewDelegate {
    func setChoosenTime(date: Date) {
        presenterController?.choosenTime = date
    }
}
