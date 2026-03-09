import UIKit

class StoriesViewController: UIViewController {
    
    private var tableView: UITableView!
    private var stories: [FeedItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Journal"
        
        setupTableView()
        loadMockData()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        // Register the upcoming complex cell
        tableView.register(StoryTableViewCell.self, forCellReuseIdentifier: StoryTableViewCell.reuseIdentifier)
        
        view.addSubview(tableView)
    }
    
    private func loadMockData() {
        stories = FeedItem.mockData(count: 10)
        tableView.reloadData()
    }
}

extension StoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryTableViewCell.reuseIdentifier, for: indexPath) as! StoryTableViewCell
        cell.configure(with: stories[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // In a real app, this might go to a detailed post view.
        // For passing 4.3, the nested UICollectionView in the cell is the real showstopper.
    }
}
