import Foundation
import UIKit

class TimePickerToolBar: UIToolbar {
    
    let spaceButton = UIBarButtonItem(
        barButtonSystemItem: .flexibleSpace,
        target: nil,
        action: nil
    )
    
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    init(label: String) {
        super.init(frame: .zero)
        self.setColors()
        self.titleLabel.text = label
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setColors() {
        self.tintColor = .white
        self.barTintColor = UIColor(red: 0.212, green: 0.212, blue: 0.212, alpha: 1)
    }
}
