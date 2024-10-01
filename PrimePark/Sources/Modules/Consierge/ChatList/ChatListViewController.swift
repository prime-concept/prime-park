import UIKit

final class ChatListViewController: UIViewController {
    private lazy var chatListView = self.view as? ChatListView

    override func loadView() {
        self.view = ChatListView()
    }

    override func viewDidLoad() {
        self.title = "Чат"
    }
}
