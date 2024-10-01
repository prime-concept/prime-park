//
//  DateComponent.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.03.2021.
//
//swiftlint:disable all
import Foundation

protocol DateComponentDelegate: class {
    func openCalendar()
    var view: DateComponentProtocol? { get set }
}

protocol DateComponentProtocol: class {
    var presenterController: ModalRouterSourceProtocol? { get }
    func setChoosenDate(date: String)
}

final class DateComponent: UIView, DateComponentProtocol, Reusable, NibFileOwnerLoadable {
    
    @IBOutlet private weak var dateLabel: UILabel!
    
    var date: String {
        get {
            dateLabel.text ?? "date nil"
        }
        set {
            dateLabel.text = newValue
        }
    }
    
    private var delegate: DateComponentDelegate?
    var presenterController: ModalRouterSourceProtocol?
    
    override init(frame: CGRect) {
        delegate = DateComponentPresenter()
        super.init(frame: frame)
        delegate?.view = self
        loadNibContent()
    }
    
    required init?(coder: NSCoder) {
        delegate = DateComponentPresenter()
        super.init(coder: coder)
        delegate?.view = self
        loadNibContent()
    }
    
    func setChoosenDate(date: String) {
        self.date = date
    }
    
    @IBAction func didTap(_ sender: Any) {
        delegate?.openCalendar()
    }
    
}
