//
//  ValetOrderPresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.05.2021.
//
//swiftlint:disable trailing_whitespace

import Foundation

protocol ValetOrderPresenterProtocol {
    func getFullVehicleDetails()
    func setFromView(ticket: String?, pin: String?)
}

final class ValetOrderPresenter: ValetOrderPresenterProtocol {
    
    weak var controller: ValetOrderControllerProtocol?
    
    private let endpoint = ValetEndpoint()
    private let networkService = NetworkService()
    private let dispatchGroup = DispatchGroup()
    
    private(set) var parkingTicket: ParkingTicket
    
    init(parkingTicket: ParkingTicket) {
        self.parkingTicket = parkingTicket
    }
    
    func setFromView(ticket: String?, pin: String?) {
        guard let ticket = ticket,
              let pin = Int(pin ?? "0")
        else { return }
        
        parkingTicket = ParkingTicket(
            ticket: ticket,
            pin: pin,
            cardType: parkingTicket.cardType,
            ticketId: parkingTicket.ticketId
        )
    }
    
    // MARK: - Private API
    
    #warning("TODO: MAKE SURE THAT THIS IS'NT COPY PATSTED BY THE PROJECT")
    
    /// - Tag: getCurrentVehicleStatus
    private func getCurrentVehicleStatus(details: VehicleDetails) {
        
        guard let token = LocalAuthService.shared.token?.accessToken else { return }
        
        dispatchGroup.enter()
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getCurrentVehicleRequestState(token: accessToken, ticket: self.parkingTicket.ticketId)
            },
            doneCompletion: { vehicleState in
                print("TUME: secondsRemaining: \(vehicleState.requestedRemainingSec)")
                details.vehicleRequestedRemainingSec = vehicleState.requestedRemainingSec
                self.controller?.vehicleDetails = details
                self.dispatchGroup.leave()
            },
            errorCompletion: { error in
                print("SHIIIT")
                self.dispatchGroup.leave()
                //self.controller?.appearValetOrderInfo(isValid: false)
                print("ERROR WHILE DOWNLOAD ISSUE TYPES LIST: \(error.localizedDescription)")
            }
        )
    }
    
    private func getVehicleHistory(details: VehicleDetails) {
        
        guard let token = LocalAuthService.shared.token?.accessToken else { return }
        dispatchGroup.enter()
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getVehicleHistory(token: accessToken, ticketId: details.ticketId ?? "")
            },
            doneCompletion: { vehicleHistory in
                print("TUME: vehicleRequestedForDtLocal: \(vehicleHistory.actual.dateTimeLocal)")
                details.vehicleRequestedForDtLocal = vehicleHistory.actual.dateTimeLocal
                
                print("FULL DETAILS: \(details.vehicleRemainingSec)")
                //details.vehicleRemainingSec = Int(Date().dateWithCurrentTimeZone() - vehicleHistory.formattedTime)
                
                print("SSS: \(vehicleHistory.formattedTime)")
                
                self.controller?.vehicleDetails = details
                self.dispatchGroup.leave()
            },
            errorCompletion: { error in
                self.dispatchGroup.leave()
                //self.controller?.appearValetOrderInfo(isValid: false)
                print("ERROR WHILE DOWNLOAD ISSUE TYPES LIST: \(error.localizedDescription)")
            }
        )
    }
	
	func getFullVehicleDetails() {
		guard let token = LocalAuthService.shared.token?.accessToken else { return }
        
		networkService.request(
			accessToken: token,
			requestCompletion: { accessToken in
                self.endpoint.getVehicleDetails(token: accessToken, tid: self.parkingTicket.ticketId)
			},
			doneCompletion: { details in
                print("AMORA: \(details.vehicleRequestedRemainingSec) \(details.vehicleRequestedForDt) \(details.vehicleRequestedForDtLocal)")
                self.getVehicleHistory(details: details)
                //self.getCurrentVehicleStatus(details: details)
                
                self.dispatchGroup.notify(queue: NetworkService.workingQueue) {
                    if let fullTime = self.controller?.vehicleDetails?.getFullTime,
                       fullTime > 0 {
                        self.controller?.forwardToTimerScreen(with: fullTime)
                    }
                }
			},
			errorCompletion: { error in
				self.controller?.vehicleDetails = nil
				print("ERROR WHILE DOWNLOAD ISSUE TYPES LIST: \(error.localizedDescription)")
			}
		)
	}
    
    func findGuestCard() {
        
        guard let token = LocalAuthService.shared.token?.accessToken else { return }
        
        let ticketRequestFormat = parkingTicket.requestFormat
        
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getVehicleDetails(
                    token: accessToken,
                    tn: ticketRequestFormat.ticket,
                    pn: ticketRequestFormat.pin
                )
            },
            doneCompletion: { details in
                print("AMORA: \(details.vehicleRequestedRemainingSec) \(details.vehicleRequestedForDt) \(details.vehicleRequestedForDtLocal)")
                //self.getCurrentVehicleStatus(details: details)
                
                self.dispatchGroup.notify(queue: NetworkService.workingQueue) {
                    if let fullTime = self.controller?.vehicleDetails?.getFullTime,
                       fullTime > 0 {
                        self.controller?.forwardToTimerScreen(with: fullTime)
                    }
                }
            },
            errorCompletion: { error in
                self.controller?.vehicleDetails = nil
                print("ERROR WHILE DOWNLOAD ISSUE TYPES LIST: \(error.localizedDescription)")
            }
        )
        
    }
}
