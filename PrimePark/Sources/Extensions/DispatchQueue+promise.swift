import Foundation
import PromiseKit

extension DispatchQueue {
	func promise<U: Thenable>(
		withGroup group: DispatchGroup? = nil,
		execute body: @escaping () throws -> U
	) -> Promise<U.T> {
		
		Promise { seal in
			self.async(group: group) {
				do {
					try body().pipe(to: seal.resolve)
				} catch {
					seal.reject(error)
				}
			}
		}
	}
}
