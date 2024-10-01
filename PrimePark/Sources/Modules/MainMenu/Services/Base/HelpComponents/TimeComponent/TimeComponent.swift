//
//  TimeComponent.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 02.03.2021.
//
//swiftlint:disable all
import UIKit

protocol TimeComponentDelegate: class {
    func openTimeController(forStart: Bool)
    var view: TimeComponentProtocol? { get set }
}

protocol TimeComponentProtocol: class {
    var presenterController: ModalRouterSourceProtocol? { get }
    func setChoosenTime(fromTime: String?, beforeTime: String?)
}

class TimeComponent: UIView, TimeComponentProtocol, Reusable, NibFileOwnerLoadable {
    
    @IBOutlet private weak var fromTimeLabel: UILabel!
    @IBOutlet private weak var beforeTimeLabel: UILabel!
    
    private var delegate: TimeComponentDelegate?
    var presenterController: ModalRouterSourceProtocol?
    
    var fromTime: String {
        get {
            return fromTimeLabel.text ?? "nil from time"
        }
        set {
            fromTimeLabel.text = newValue
        }
    }
    
    var beforeTime: String {
        get {
            return beforeTimeLabel.text ?? "nil before time"
        }
        set {
            beforeTimeLabel.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        delegate = TimeComponentPresenter()
        super.init(frame: frame)
        delegate?.view = self
        loadNibContent()
    }
    
    required init?(coder: NSCoder) {
        delegate = TimeComponentPresenter()
        super.init(coder: coder)
        delegate?.view = self
        loadNibContent()
    }
    
    @IBAction func chooseFromTime(_ sender: Any) {
        delegate?.openTimeController(forStart: true)
    }
    
    @IBAction func chooseBeforeTime(_ sender: Any) {
        delegate?.openTimeController(forStart: false)
    }
    
    func setChoosenTime(fromTime: String?, beforeTime: String?) {
        if let from = fromTime {
            self.fromTime = from
        }
        if let before = beforeTime {
            self.beforeTime = before
        }
    }
    
}
