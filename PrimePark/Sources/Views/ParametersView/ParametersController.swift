//
//  ParametersController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 31.05.2021.
//

import UIKit

protocol ParametersControllerProtocol: class {
    func setTitleLabel(str: String)
}

struct ParametersData {
    var name: String
    var isSelected: Bool = false
}

class ParametersController: PannableViewController, ParametersControllerProtocol {
    
    private lazy var parametersView: ParametersView = {
        return Bundle.main.loadNibNamed("ParametersView", owner: self, options: nil)?.first as? ParametersView ?? ParametersView()
    }()
    
    var presenter: ParametersPresenterProtocol
    
    var content: [ParametersData] = []
    var selectedRow: Int
    
    var choosenClosure: ((ParametersData, Int) -> Void)?
    
    func reloadData() {
        parametersView.reloadData()
    }
    
    init(
        presenter: ParametersPresenterProtocol,
        content: [ParametersData],
        selectedRow: Int = 0
    ) {
        self.presenter = presenter
        self.content = content
        self.selectedRow = selectedRow
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = parametersView
        parametersView.commonInit(delegate: self)
        reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setTitleLabel(str: String) {
        parametersView.title = str
    }
}

extension ParametersController: ParametersViewDelegate {
    var contentCount: Int {
        return content.count
    }
    
    var dynamicSize: CGFloat {
        return CGFloat(content.count * 44) + 150
    }
    
    func select(row: Int) {
        print(selectedRow)
        content[selectedRow].isSelected = false
        selectedRow = row
        content[row].isSelected = true
        choosenClosure?(content[row], row)
    }
}
