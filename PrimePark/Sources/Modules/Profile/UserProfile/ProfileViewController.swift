import UIKit
//swiftlint:disable trailing_whitespace
protocol ProfileControllerProtocol: class, PushRouterSourceProtocol {
    func needSetImage(_ image: UIImage)
    func needUpdateImage(user: User)
    func setResidentNumber(_ residentCount: Int)
    var viewProtocol: ApplyingLabelProtocol { get }
}

final class ProfileController: UIViewController {
    private lazy var profileView: ProfileView = {
        let view = Bundle.main.loadNibNamed("ProfileView", owner: nil, options: nil)?.first as? ProfileView ?? ProfileView()
        return view
    }()
    private let imagePicker = UIImagePickerController()
    
    private var apartmentList: ApartmentList?
    private let presenter: ProfilePresenterProtocol
    private let user: User?
    private let currentRoom: Room?
    private var infoView: InfoView?

    init(presenter: ProfilePresenterProtocol, user: User?, room: Room?) {
        self.presenter = presenter
        self.user = user
        self.currentRoom = room
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.profileView
        profileView.setDelegate(self)
        profileView.commonInit()
        profileView.setUser(user, room: currentRoom)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let room = LocalAuthService.shared.apartment else { return }
        profileView.applyRoomFormat(
            format: room.strFormat(),
            currentRoom: room
        )
    }
}

extension ProfileController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}

//swiftlint:disable trailing_whitespace
extension ProfileController: ProfileViewDelegate {
    func changeApartment() {
        apartmentList = ApartmentList(view: profileView)
        apartmentList?.title = "Выберите квартиру"
        ModalRouter(source: self, destination: apartmentList?.make() ?? UIViewController(), modalPresentationStyle: .custom).route()
    }
    
    func showApartments(_ user: User?, currentRoom: Room?) {
        self.presenter.showApartments(user, currentRoom: currentRoom)
    }
    
    func showPasses() {
        push(module: PassForMeListAssembly(authService: LocalAuthService.shared).make())
    }
    
    func showLawInfo() {
        self.presenter.showLawInfo()
    }
    
    func openSettings() {
        self.presenter.openSettings()
    }

    func showResidents() {
        presenter.showResidents()
    }
}

extension ProfileController: ProfileControllerProtocol {

    func setResidentNumber(_ residentCount: Int) {
        profileView.setResidentCount(residentCount)
    }
    
    var viewProtocol: ApplyingLabelProtocol {
        return profileView
    }
    
    func needSetImage(_ image: UIImage) {

    }
    
    func chooseImage() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func needUpdateImage(user: User) {
        profileView.setUser(user)
    }
}

//swiftlint:disable colon
extension ProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        dismiss(animated: true) {
            self.presenter.postImg(img: pickedImage)
        }
    }
}
