//
//  CounterController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 16.03.2021.
//

import UIKit

protocol CounterControllerProtocol: class {
    func setCountersHistory(history: [Counter])
}

//swiftlint:disable trailing_whitespace
class CounterController: UIViewController {
    private var style: Counter.Measure
    private lazy var counterView: CounterView = {
        return Bundle.main.loadNibNamed("CounterView", owner: nil, options: nil)?.first as? CounterView ?? CounterView()
    }()
    
    var presenter: CounterPresenterProtocol?
    
    override func loadView() {
        view = counterView
        counterView.commonInit()
        counterView.style = style
        counterView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        counterView.title = style.rawValue
        
        presenter?.getCountersHistory()
    }
    
    init(style: Counter.Measure) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.style = .cube()
        super.init(coder: coder)
    }
}

extension CounterController: CounterControllerProtocol {
    func setCountersHistory(history: [Counter]) {
        counterView.setCountersHistory(history: history)
    }
}

extension CounterController: CounterViewDelegate {
    func tapBack() {
        pop()
    }
}
