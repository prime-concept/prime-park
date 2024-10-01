import Nuke
import UIKit

extension UIImageView {
    func loadImage(from url: URL) {
        
        self.animateSkeleton()
        Nuke.loadImage(with: ImageRequest(url: url), options: .shared, into: self, progress: nil) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success:
                self.hideSkeleton()
            }
        }
    }
}
