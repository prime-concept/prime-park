import UIKit

// swiftlint:disable trailing_whitespace

extension Notification.Name {
    static let roomChanged = Notification.Name("roomChanged")
}

protocol ProfilePresenterProtocol: class {
    func openSettings()
    func showResidents()
    func showLawInfo()
    func showApartments(_ user: User?, currentRoom: Room?)
    func postImg(img: UIImage)
}

final class ProfilePresenter: ProfilePresenterProtocol {
    private let authService: LocalAuthService
    private let endpoint: SettingsEndpoint
    private let requestService = RequestService.shared
    private let networkService = NetworkService()
    weak var controller: ProfileControllerProtocol?

    init(authService: LocalAuthService, endpoint: SettingsEndpoint) {
        self.authService = authService
        self.endpoint = endpoint
        loadResidents()
        addListener()
    }

    // MARK: - ProfilePresenterProtocol

    func openSettings() {
        PushRouter(source: self.controller, destination: SettingsAssembly(authService: authService).make()).route()
    }

    func showResidents() {
        PushRouter(source: self.controller, destination: ResidentListAssembly(authService: authService).make()).route()
    }

    func showLawInfo() {
        ModalRouter(source: nil, destination: WebViewController(stringURL: WebViewInfoLinksConstants.lawInfo), modalPresentationStyle: .popover).route()
        //ModalRouter(source: nil, destination: LawInfoController(), modalPresentationStyle: .popover).route()
    }
    func showApartments(_ user: User?, currentRoom: Room?) {
        PushRouter(source: self.controller, destination: FullDescriptionApartmentAssembly(user, currentRoom: currentRoom).make()).route()
    }

    // MARK: - Private API

    private func loadImage() {
        #warning("NOT IN USE")
        guard let user = self.authService.user else { return }
        let avatar = user.avatar
        
        if !avatar.isEmpty {
            networkService.request(
                isRefreshing: false,
				accessToken: "",
				requestCompletion: { _ in
                    self.endpoint.loadImage(at: avatar)
                },
                doneCompletion: { imageData in
                    let image = UIImage(data: imageData)
                    if let image = image {
                        self.controller?.needSetImage(image)
                    }
                },
                errorCompletion: { error in
                    print("ERROR WHILE LOAD INFO ABOUT USER IN SETTINGS: \(error.localizedDescription)")
                }
            )
        }
    }
    
    func postImg(img: UIImage) {
        guard let token = self.authService.token?.accessToken,
              let imgData = downsample(
                imageAt: img.jpegData(compressionQuality: 1.0) ?? Data(),
                to: CGSize(width: 400, height: 400),
                scale: 1.0
              ) else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.postProfileImg(token: accessToken, imgData: imgData)
            },
            doneCompletion: { imgURL in
                print(imgURL)
                self.changeProfileImg(imgURL: imgURL)
            },
            errorCompletion: { error in
                print("ERROR WHILE POSTING IMG: \(error.localizedDescription)")
            }
        )
    }
    
    func changeProfileImg(imgURL: String) {
        guard let token = self.authService.token?.accessToken else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.changeProfileImg(token: accessToken, imgURL: imgURL)
            },
            doneCompletion: { updatedUser in
                self.authService.updateUser(user: updatedUser)
                self.controller?.needUpdateImage(user: updatedUser)
            },
            errorCompletion: { error in
                print("ERROR WHILE CHANGING PROFILE AVATAR: \(error.localizedDescription)")
            }
        )
    }
    
    private func loadResidents() {
        guard let token = self.authService.token?.accessToken else { return }
		guard let room = self.authService.room else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getResidentsList(room: String(room.id), token: accessToken)
            },
            doneCompletion: { list in
                self.controller?.setResidentNumber(list.count)
            },
            errorCompletion: { error in
                print("ERROR WHILE LOAD RESIDENT LIST: \(error.localizedDescription)")
            }
        )
    }
}

extension ProfilePresenter {
    //swiftlint:disable force_unwrapping trailing_whitespace
    private func downsample(imageAt imageData: Data, to pointSize: CGSize, scale: CGFloat) -> Data? {
        
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions)!
     
        let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
     
        let downsampledOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels
        ] as CFDictionary
        
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions)!
     
        return UIImage(cgImage: downsampledImage).jpegData(compressionQuality: 0.5)
    }
    
    private func setupImage(img: UIImage) -> Data? {
        guard let imgData = downsample(
            imageAt: img.jpegData(compressionQuality: 1.0) ?? Data(),
            to: CGSize(width: 400, height: 400),
            scale: 1.0
        )
        else { return nil }
        
        return imgData
    }
}

extension ProfilePresenter {
    @objc
    func reloadData() {
        self.loadResidents()
    }
    
    func addListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData),
            name: .roomChanged,
            object: nil
        )
    }
}
