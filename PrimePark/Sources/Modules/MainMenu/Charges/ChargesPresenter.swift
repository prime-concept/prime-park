//
//  ChargesPresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 15.03.2021.
//

//swiftlint:disable all
protocol ChargesPresenterProtocol {
	func requestAll()
    func toPay() -> String
}

final class ChargesPresenter: ChargesPresenterProtocol {
    weak var controller: ChargesControllerProtocol?
    
    private let authService: LocalAuthService = .shared
    private let endpoint: ChargesEndpoint = .init()
    private let networkService = NetworkService()
	private let dispatchGroup = DispatchGroup()
    
    private var balance: Balance?
	
	func requestAll() {
		
		getBalance()
		
        dispatchGroup.notify(queue: NetworkService.workingQueue) {
			self.getInvoices()
			self.getCounters()
		}
	}
	
	private func getBalance() {
		guard let token = self.authService.token?.accessToken else { return }
		
        dispatchGroup.enter()
		networkService.request(
			withGroup: dispatchGroup,
			accessToken: token,
			requestCompletion: { accessToken in
				self.endpoint.getBalance(room: "\(self.authService.apartment?.id ?? 0)", token: accessToken)
			},
			doneCompletion: { balance in
				self.dispatchGroup.leave()
				self.balance = balance
				self.controller?.setBalance(balance: balance.strCurrency)
			},
			errorCompletion: { error in
				print("ERROR WHILE DOWNLOAD ONE-IME PARKING LIST: \(error.localizedDescription)")
                self.dispatchGroup.leave()
			}
		)
	}
    
    private func getInvoices() {
        guard let token = self.authService.token?.accessToken else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getInvoices(room: "\(self.authService.apartment?.id ?? 0)", token: accessToken)
            },
            doneCompletion: { invoices in
                let invoices = invoices.sorted(by: {
                    $0.month.compare($1.month) == .orderedDescending
                })
                self.controller?.setInvoices(invoices: invoices)
            },
            errorCompletion: { error in
                print("ERROR WHILE REQUESTING INVOICES: \(error.localizedDescription)")
            }
        )
    }
    
    private func getCounters() {
        guard let token = self.authService.token?.accessToken else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getCounters(room: "\(self.authService.apartment?.id ?? 0)", token: accessToken)
            },
            doneCompletion: { counters in
                var uniqueArr = Array(Set(counters))
                uniqueArr = uniqueArr.sorted()
                self.controller?.setCounters(counters: uniqueArr)
            },
            errorCompletion: { error in
                print("ERROR WHILE REQUESTING COUNTERS: \(error.localizedDescription)")
            }
        )
    }
    
    func toPay() -> String {
        guard let balance = balance else { return "0" }
        return "\(balance.toPay)"
    }
}
