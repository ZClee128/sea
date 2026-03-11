import UIKit

class CollectionListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Boards"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewBoard))
    }
    
    @objc private func createNewBoard() {
        let alert = UIAlertController(title: "New Board", message: "Enter a name for your new inspiration board.", preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "E.g. Cyberpunk" }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                CollectionManager.shared.createCollection(name: text)
                self.tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension CollectionListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CollectionManager.shared.collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let collection = CollectionManager.shared.collections[indexPath.row]
        cell.textLabel?.text = collection.name
        cell.detailTextLabel?.text = "\(collection.imageIds.count) imgs"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let collection = CollectionManager.shared.collections[indexPath.row]
        let detailVC = FavoritesViewController() // Will reuse this for displaying images within a folder
        detailVC.title = collection.name
        detailVC.collectionId = collection.id
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let collection = CollectionManager.shared.collections[indexPath.row]
            CollectionManager.shared.deleteCollection(id: collection.id)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
