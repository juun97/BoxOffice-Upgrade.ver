//
//  BoxOfficeListViewController.swift
//  BoxOffice
//
//  Created by Rhode, Rilla on 2023/03/20.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

struct MainDataSection {
    var header: String
    var items: [DailyBoxOffice]
}

extension MainDataSection: SectionModelType {
    init(original: MainDataSection, items: [DailyBoxOffice]) {
        self = original
        self.items = items
    }
}

final class BoxOfficeListViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = BoxOfficeListViewModel()
    private var dataSource: RxCollectionViewSectionedReloadDataSource<MainDataSection>!
    
    
    private let server = NetworkManager.shared
    private let urlMaker = URLRequestMaker()
    private var boxOffice: BoxOffice?
    private var currentDate: String = Date.yesterday.convertString(isFormatted: false)
    private var cellMode: CellMode = CellMode.list
    
    private let loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .large)
        loadingIndicatorView.color = .systemGray3
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicatorView.hidesWhenStopped = true
        
        return loadingIndicatorView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CustomCollectionViewListCell.self,
                                forCellWithReuseIdentifier: CustomCollectionViewListCell.identifier)
        collectionView.register(CustomCollectionViewIconCell.self,
                                forCellWithReuseIdentifier: CustomCollectionViewIconCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureLayout()
        
        //loadingIndicatorView.startAnimating()
        configureViewController()
        configureDataSource()
        configureCollectionView()
        configureRefreshControl()
        
        bind()
        fetchData()
    }
    
    // MARK: - UILogic
    private func configureUI() {
        view.addSubview(collectionView)
        view.addSubview(loadingIndicatorView)
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            loadingIndicatorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            loadingIndicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        
        readCellMode()
    }
    
    func bind() {
        viewModel.boxOffice
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(DailyBoxOffice.self)
            .subscribe(onNext: { model in
                let detailMovieViewController = DetailMovieViewController(movieCode: model.movieCode)
                
                self.navigationController?.pushViewController(detailMovieViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func readCellMode() {
        guard let data = UserDefaults.standard.data(forKey: CellMode.identifier) else {
            cellMode = .list
            return
        }
        
        let result = DecodeManager().decodeJSON(data: data, type: CellMode.self)
        
        do {
            guard let storedCellMode = try verifyResult(result: result) else { return }
            self.cellMode = storedCellMode
            UserDefaults.standard.removeObject(forKey: CellMode.identifier)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func configureDataSource() {
        dataSource = RxCollectionViewSectionedReloadDataSource<MainDataSection> { dataSource, tableView, indexPath, item in
            switch self.cellMode {
            case .list:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewListCell.identifier, for: indexPath) as? CustomCollectionViewListCell else { return CustomCollectionViewListCell() }
                cell.configureCell(dailyBoxOffice: item)
                
                return cell
            case .icon:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewIconCell.identifier, for: indexPath) as? CustomCollectionViewIconCell else { return CustomCollectionViewIconCell() }
                cell.configureCell(dailyBoxOffice: item)
                
                return cell
            }
        }
    }
    
    private func configureViewController() {
        view.backgroundColor = .white
        title = currentDate.formatDateString(format: DateFormat.yearMonthDay)
        
        let selectDateButton: UIBarButtonItem = {
            let button = UIBarButtonItem(title: "날짜 선택",
                                         style: .plain,
                                         target: self,
                                         action: #selector(presentSelectDateModal))
            return button
        }()
        self.navigationItem.rightBarButtonItem = selectDateButton
        
        self.navigationController?.isToolbarHidden = false
        
        let selectModeButton: UIBarButtonItem = {
            let button = UIBarButtonItem(title: "화면 모드 변경",
                                         style: .plain,
                                         target: self,
                                         action: #selector(presentCellChangeActionSheet))
            return button
        }()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [flexibleSpace, selectModeButton, flexibleSpace]
    }
    
    @objc private func presentSelectDateModal() {
        let modal = CalendarViewController(currentDate)
        modal.delegate = self
        
        self.present(modal, animated: true)
    }
    
    @objc private func presentCellChangeActionSheet() {
        let actionSheet = UIAlertController(title: "화면모드변경", message: nil, preferredStyle: .actionSheet)
        let actionDefault = createAlertAction()
        let actionCancel = UIAlertAction(title: "취소", style: .cancel)
        
        actionSheet.addAction(actionDefault)
        actionSheet.addAction(actionCancel)
        
        self.present(actionSheet, animated: true)
    }
    
    private func createAlertAction() -> UIAlertAction {
        var action: UIAlertAction
        
        switch cellMode {
        case .list:
            action = UIAlertAction(title: cellMode.alertText, style: .default) { [weak self] _ in
                self?.cellMode = .icon
                self?.collectionView.reloadData()
                self?.registerCellMode()
            }
        case .icon:
            action = UIAlertAction(title: cellMode.alertText, style: .default) { [weak self] _ in
                self?.cellMode = .list
                self?.collectionView.reloadData()
                self?.registerCellMode()
            }
        }
        
        return action
    }
    
    private func registerCellMode() {
        let encoder = JSONEncoder()
        let encodedData = try? encoder.encode(cellMode)
        UserDefaults.standard.set(encodedData, forKey: CellMode.identifier)
    }
    
    private func configureRefreshControl() {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self,
                                                 action: #selector(handleRefreshControl),
                                                 for: .valueChanged)
    }
    
    @objc private func handleRefreshControl() {
        self.currentDate = Date.yesterday.convertString(isFormatted: false)
        configureViewController()
        configureCollectionView()
    }
    
    // MARK: - Business Logic
    
    
    private func fetchData() {
        viewModel.fetchData()
    }

    private func verifyResult<T, E: Error>(result: Result<T, E>) throws -> T? {
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
 
}

extension BoxOfficeListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch cellMode {
        case .list:
            return collectionViewWithList()
        case .icon:
            return  collectionViewWithIcon(collectionViewLayout: collectionViewLayout)
        }
        
    }
    
    private func collectionViewWithIcon(collectionViewLayout: UICollectionViewLayout) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize() }
        
        let numberOfCells: CGFloat = 2.2
        let width = collectionView.frame.size.width - (flowLayout.minimumInteritemSpacing * (numberOfCells-1))
        
        return CGSize(width: width/(numberOfCells), height: width/(numberOfCells))
    }
    
    private func collectionViewWithList() -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        
        let itemsPerRow: CGFloat = 8
        let itemsPerColumn: CGFloat = 1
        
        let cellWidth = width / itemsPerColumn
        let cellHeight = height / itemsPerRow
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let movieCode = self.boxOffice?.boxOfficeResult.dailyBoxOfficeList[index: indexPath.item]?.movieCode else {
            return
        }
        let detailMovieViewController = DetailMovieViewController(movieCode: movieCode)
        
        navigationController?.pushViewController(detailMovieViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard cellMode == .icon else { return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) }
        
        return UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard cellMode == .icon else { return 0 }
        
        return 15.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard cellMode == .icon else { return 0 }
        
        return 10.0
    }
}

extension BoxOfficeListViewController: CalendarViewControllerDelegate {
    func deliverData(_ data: String) {
        self.currentDate = data
        
        configureViewController()
        configureCollectionView()
    }
}


