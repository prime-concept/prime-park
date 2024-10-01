import UIKit

protocol ChooseLanguageViewDelegate: class {
    func pickLanguage(language: Language)
}

class ChooseLanguageView: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var rusLanguageLabel: LocalizableLabel!
    @IBOutlet weak var enLanguageLabel: LocalizableLabel!
    @IBOutlet weak var ruCheckBox: UIImageView!
    @IBOutlet weak var enCheckBox: UIImageView!
    
    var labelArr: [UILabel] = []
    var imgArr: [UIImageView] = []
    private weak var delegate: ChooseLanguageViewDelegate?
    private var doesInit = true
    var currentLanguage: Language = LocalAuthService.shared.choosenLanguage ?? .english {
        didSet {
            for one in labelArr {
                one.textColor = Palette.darkLightColor
            }
            for one in imgArr {
                one.isHidden = true
            }
            labelArr[currentLanguage.rawValue].textColor = .white
            imgArr[currentLanguage.rawValue].isHidden = false
            if !doesInit {
                self.delegate?.pickLanguage(language: currentLanguage)
            }
            doesInit = false
        }
    }
    func commonInit() {
        labelArr = [rusLanguageLabel, enLanguageLabel]
        imgArr = [ruCheckBox, enCheckBox]
//        subscribeOnLanguageChanging()
    }
    init(delegate: ChooseLanguageViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func addDelegate(delegate: ChooseLanguageViewDelegate) {
        self.delegate = delegate
    }
    @IBAction func tapRussian(_ sender: Any) {
        currentLanguage = .russian
    }
    @IBAction func tapEnglish(_ sender: Any) {
        currentLanguage = .english
    }
}
