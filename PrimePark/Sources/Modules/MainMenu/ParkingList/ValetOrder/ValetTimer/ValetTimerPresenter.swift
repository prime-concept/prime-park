//
//  ValetTimerPresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 07.05.2021.
//
// swiftlint:disable trailing_whitespace
import Foundation

protocol ValetTimerPresenterProtocol {
    func makeTimeFormat(seconds: Int) -> String
    func startCountDown()
    func stopTimer()
    // Requests
    func stopServe()
    
    func changeTime(newInterval: TimeInterval)
    
    var readyToFire: ((Int, Float) -> Void)? { get set }
}

final class ValetTimerPresenter: ValetTimerPresenterProtocol {
    
    typealias OpeningStatus = ValetTimerAssembly.OpeningState

    weak var controller: ValetTimerControllerProtocol?
    private let endpoint = ValetEndpoint()
    private let networkService = NetworkService()
    
    private let workingQueue = DispatchQueue.global(qos: .background)
    
    private let parkingTicket: ParkingTicket
    private var allSeconds: Int = 0
    private var openingState: OpeningStatus
    
    private var repeatingTimer: RepeatingTimer?
    
    var readyToFire: ((Int, Float) -> Void)?
    
    var secondsLeft: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.controller?.waitTime = self.makeTimeFormat(seconds: self.secondsLeft)
            }
        }
    }
    
    init(
        parkingTicket: ParkingTicket,
        openingState: OpeningStatus
    ) {
        self.parkingTicket = parkingTicket
        self.openingState = openingState
        
        switch openingState {
        case .creating(let interval):
            self.setTime(interval: interval)
        default:
            break
        }
        
        repeatingTimer = RepeatingTimer(
            timeInterval: TimeInterval(allSeconds),
            workingQueue: workingQueue
        )
        
        repeatingTimer?.eventHandler = { [weak self] in
            self?.didTimerTick()
        }
        
        addObservers()
    }
    
    deinit {
        repeatingTimer?.suspend()
        removeObservers()
    }
    
    func startCountDown() {
        switch openingState {
        case .creating(_):
            serveCar(parkingTicket: parkingTicket, minutes: allSeconds / 60)
        case .existing:
            getVehicleRemainingSeconds()
        }
    }
    
    func stopTimer() {
        controller?.isForcedToRemove = true
        secondsLeft = 0
        repeatingTimer?.suspend()
    }
    
    private func setTime(interval: TimeInterval) {
        self.secondsLeft = Int(interval)
        
        if case .existing(let fullTime) = openingState {
            allSeconds = Int(fullTime)
        } else {
            allSeconds = Int(interval)
        }
    }
    
    // MARK: - Timer Methods
    private func startTimer() {
        repeatingTimer?.resume()
    }
    
    @objc
    private func didTimerTick() {
        self.secondsLeft -= 1

        if self.secondsLeft == 0 {
            repeatingTimer?.suspend()
            return
        }
    }
    
    func changeTime(newInterval: TimeInterval) {
        setTime(interval: newInterval)
        openingState = .creating(newInterval)
        
        startCountDown()
        
        //serveCar(parkingTicket: parkingTicket, minutes: newInterval.toMinutes())
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(getVehicleRemainingSeconds), name: .willEnterForeground, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .willEnterForeground, object: nil)
    }
    
    // MARK: - Requests
    
    func stopServe() {
        guard let token = LocalAuthService.shared.token?.accessToken else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.stopVehicleRequest(
					token: accessToken,
                    tid: self.parkingTicket.ticketId
				)
            },
            doneCompletion: { response in
                print(response)
            },
            errorCompletion: { error in
                print("ERROR WHILE DOWNLOAD ISSUE TYPES LIST: \(error.localizedDescription)")
            }
        )
    }
    
    private func serveCar(parkingTicket: ParkingTicket, minutes: Int) {
        
        guard let token = LocalAuthService.shared.token?.accessToken else { return }
        
        LoadingService.startLoading()
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.requestVehicle(
                    token: accessToken,
                    tid: parkingTicket.ticketId,
                    minutesToRequest: minutes
                )
            },
            doneCompletion: { _ in
                LoadingService.stopLoading()
                
                self.readyToFire?(self.allSeconds, 0)
                self.startTimer()
            },
            errorCompletion: { error in
                LoadingService.stopLoading()
                
                self.controller?.errorAlert()
                print("ERROR WHILE DOWNLOAD ISSUE TYPES LIST: \(error.localizedDescription)")
            }
        )
    }
    
    @objc
    private func getVehicleRemainingSeconds() {
        
        LoadingService.startLoading()
        
        guard let token = LocalAuthService.shared.token?.accessToken else { return }
        
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getCurrentVehicleRequestState(token: accessToken, ticket: self.parkingTicket.ticketId)
            },
            doneCompletion: { vehicleState in
                
                LoadingService.stopLoading()
                
                let secondsRemain = Float(vehicleState.requestedRemainingSec ?? 60 * 9)
                
                self.setTime(interval: Double(secondsRemain))
                
                self.readyToFire?(Int(secondsRemain), 1.0 - secondsRemain / Float(self.allSeconds))
                self.startTimer()
            },
            errorCompletion: { error in
                print("ERROR WHILE DOWNLOAD ISSUE TYPES LIST: \(error.localizedDescription)")
                
                LoadingService.stopLoading()
                
                self.controller?.errorAlert()
            }
        )
    }
}

extension ValetTimerPresenter {
    // swiftlint:disable force_unwrapping
    func makeTimeFormat(seconds: Int) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        
        switch seconds {
        case 86400...:
            dateFormatter.dateFormat = "dd д. HH ч."
        case 3600...:
            dateFormatter.dateFormat = "HH ч. mm м."
        default:
            dateFormatter.dateFormat = "mm м. ss с."
        }
        
        var date = Date(timeIntervalSince1970: Double(seconds))
        
        date += .day(-1)
        
        print(dateFormatter.string(from: date))
        
        return dateFormatter.string(from: date)
    }
}
