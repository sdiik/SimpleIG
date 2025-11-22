import UIKit
import Kingfisher

final class HomeViewController: UIViewController {

    private let tableView = UITableView()
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var storiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 100)
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(StoryCell.self, forCellWithReuseIdentifier: StoryCell.identifier)
        return cv
    }()

    private let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupStoriesHeader()
        loadInitialData()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didPullToRefresh),
                                               name: .didCreateNewPost,
                                               object: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isHidden = true
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    @objc private func didTapCamera() {
        navigationController?.pushViewController(ProfilePhotoViewController(), animated: true)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 800
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor) ])
    }
 
    @objc private func didPullToRefresh() {
        Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.loadInitialData()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.storiesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func setupStoriesHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 120))
        headerView.addSubview(storiesCollectionView)

        storiesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            storiesCollectionView.topAnchor.constraint(equalTo: headerView.topAnchor),
            storiesCollectionView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            storiesCollectionView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            storiesCollectionView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        tableView.tableHeaderView = headerView
    }

    private func loadInitialData() {
        Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.loadInitialData()

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.storiesCollectionView.reloadData()
            }
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PostTableViewCell.identifier,
            for: indexPath
        ) as? PostTableViewCell else { return UITableViewCell() }
        
        let post = viewModel.posts[indexPath.row]
        
        Task {
            let comments = try await viewModel.fetchComment(postId: post.id)
            cell.configure(with: post, commnets: comments)
        }

        cell.likeButtonAction = { [weak self] in
            guard let self = self else { return }
            Task {
                await self.viewModel.likePost(postId: post.id, isLiked: cell.isLiked)
                cell.isLiked.toggle()
                cell.updateLikeCount()
            }
        }
        
        cell.shareButtonAction = { [weak self] in
            guard let self = self else { return }
            let post = self.viewModel.posts[indexPath.row]
            
            self.viewModel.shareItems(for: post) { items in
                let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = cell.shareButton
                self.present(activityVC, animated: true)
            }
        }
        
        cell.sendCommentAction = { [weak self] comment in
            guard let self = self else { return }
            Task {
                await self.viewModel.comment(postId: post.id, comment: comment)
                await self.viewModel.fetchLikes(postId: post.id)
                let updatedComments = await self.viewModel.fetchComment(postId: post.id)
                cell.commnets = updatedComments
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StoryCell.identifier,
            for: indexPath
        ) as? StoryCell else { return UICollectionViewCell() }

        let user = viewModel.users[indexPath.row]
        cell.configure(with: user)
        return cell
    }
}
