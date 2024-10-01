//swiftlint:disable trailing_whitespace
class ErrorPresenter {
    // MARK: - Internal API

    internal func identifyError(error: Error, source: ModalRouterSourceProtocol?) {
        switch error {
        case PrimeParkError.createPassNameLengthError:
            self.showNameLengthError(source: source)
        case PrimeParkError.createPassTemplateError:
            self.showTemplateError(source: source)
        case PrimeParkError.createPassRoleError:
            self.showRoleError(source: source)
        case PrimeParkError.createPassPhoneError:
            self.showPhoneError(source: source)
        default:
            self.showRequestError(source: source)
        }
    }
    
    internal func showAlert(title: String, subtitle: String?, source: ModalRouterSourceProtocol?) {
        let assembly = InfoAssembly(title: title, subtitle: subtitle, delegate: nil)
        let router = ModalRouter(source: source, destination: assembly.make())
        router.route()
    }

    internal func showNoCarDataError(source: ModalRouterSourceProtocol?) {
        showAlert(
            title: Localization.localize("createPass.noCarNumber.title"),
            subtitle: nil,
            source: source
        )
    }

    internal func showGuestsError(source: ModalRouterSourceProtocol?) {
        showAlert(
            title: Localization.localize("createPass.addGuest.limit.title"),
            subtitle: Localization.localize("createPass.addGuest.limit.subtitle"),
            source: source
        )
    }

    internal func showNoGuestsError(source: ModalRouterSourceProtocol?) {
        showAlert(
            title: Localization.localize("createPass.noGuests.title"),
            subtitle: Localization.localize("createPass.noGuests.subtitle"),
            source: source
        )
    }

    internal func showRequestError(source: ModalRouterSourceProtocol?) {
        showAlert(
            title: Localization.localize("createPass.requestError.title"),
            subtitle: Localization.localize("createPass.requestError.subtitle"),
            source: source
        )
    }

    internal func showSuccessInfo(source: ModalRouterSourceProtocol?) {
        showAlert(
            title: Localization.localize("createPass.requestSuccess.title"),
            subtitle: nil,
            source: source
        )
    }
    
    internal func showSuccessOneTimeInfo(source: ModalRouterSourceProtocol?, idArr: [Int]) {
        let rawSubtitle = Localization.localize(idArr.count < 2 ? "createPass.oneTime.requestSuccess.subtitle" : "createPass.oneTime.multi.requestSuccess.subtitle")
        showAlert(
            title: Localization.localize("createPass.oneTime.requestSuccess.title"),
            subtitle: rawSubtitle.replacingOccurrences(of: "{n}", with: "\(idArr.sorted().customDescription)"),
            source: source
        )
    }
    
    internal func showSuccessNoOneTimeInfo(source: ModalRouterSourceProtocol?, idArr: [Int]) {
        let rawSubtitle = Localization.localize(idArr.count < 2 ? "createPass.noOneTime.requestSuccess.subtitle" : "createPass.noOneTime.multi.requestSuccess.subtitle")
        showAlert(
            title: Localization.localize("createPass.noOneTime.requestSuccess.title"),
            subtitle: rawSubtitle.replacingOccurrences(of: "{n}", with: "\(idArr.sorted().customDescription)"),
            source: source
        )
    }
    
    internal func showParkingAlert(source: ModalRouterSourceProtocol?) {
        showAlert(
            title: Localization.localize("createPass.parkingAlert.title"),
            subtitle: nil,
            source: source
        )
    }

    // MARK: - Private API

    private func showNameLengthError(source: ModalRouterSourceProtocol?) {
        showAlert(
            title: Localization.localize("createPass.requestError.title"),
            subtitle: Localization.localize("createPass.requestError.nameLength.subtitle"),
            source: source
        )
    }

    private func showTemplateError(source: ModalRouterSourceProtocol?) {
        showAlert(
            title: Localization.localize("createPass.requestError.title"),
            subtitle: Localization.localize("createPass.requestError.template.subtitle"),
            source: source
        )
    }

    private func showRoleError(source: ModalRouterSourceProtocol?) {
        showAlert(
            title: Localization.localize("createPass.requestError.title"),
            subtitle: Localization.localize("createPass.requestError.role.subtitle"),
            source: source
        )
    }

    private func showPhoneError(source: ModalRouterSourceProtocol?) {
        showAlert(
            title: Localization.localize("createPass.requestError.title"),
            subtitle: Localization.localize("createPass.requestError.phone.subtitle"),
            source: source
        )
    }
}

class PassWithErrorPresenter: ErrorPresenter {

    internal var guests: [Guest] = []
    internal var amountOfRequests = 0
    internal var idArr: [Int] = []
    internal var needError = false

    // MARK: - Internal API

    internal func calculateAmountOfRequests(
        source: CreatePassControllerProtocol?,
        phone: String,
        requestType: CreatePassRequest = .oneTimeRequest
    ) {
        self.amountOfRequests -= 1
        if self.amountOfRequests == 0 && self.needError {
            if self.amountOfRequests == 0 {
                self.updateGuests(source: source)
            }
            self.showRequestError(source: source)
        }
        guard let index = self.getIndexForPhone(phone) else { return }
        self.guests.remove(at: index)
        if self.guests.isEmpty {
            if requestType == .oneTimeRequest {
                self.showSuccessOneTimeInfo(source: source, idArr: idArr)
            } else {
                self.showSuccessNoOneTimeInfo(source: source, idArr: idArr)
            }
            //self.showSuccessInfo(source: source)
            source?.dismissController()
        }
    }

    internal func updateGuests(source: CreatePassControllerProtocol?) {
        source?.updateGuests(self.guests)
    }

    internal func showParkingAlert(source: CreatePassControllerProtocol?) {
        showAlert(title: Localization.localize("createPass.parkingAlert.title"), subtitle: nil, source: source)
    }

    // MARK: - Private API

    private func getIndexForPhone(_ phone: String) -> Int? {
        for guest in guests {
            if guest.removePhoneFormat == phone {
                return guests.firstIndex(of: guest)
            }
        }
        return nil
    }
}
