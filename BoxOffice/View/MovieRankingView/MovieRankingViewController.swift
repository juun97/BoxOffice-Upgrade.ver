//
//  MovieRankingViewController.swift
//  BoxOffice
//
//  Created by Rhode, Rilla on 2023/03/20.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import RxViewController

struct MovieRankingViewDataSection: ObservableConvertibleType {
    typealias Element = MovieRankingViewDataSection
    
    var header: String
    var items: [DailyBoxOffice]
    
    func asObservable() -> Observable<MovieRankingViewDataSection> {
        return Observable.just(self)
    }
}

extension MovieRankingViewDataSection: SectionModelType {
    init(original: MovieRankingViewDataSection, items: [DailyBoxOffice]) {
        self = original
        self.items = items
    }
}

final class MovieRankingViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = MovieRankingViewModel()
    private var dataSource: RxCollectionViewSectionedReloadDataSource<MovieRankingViewDataSection>!

    //MARK: - UI
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
    
    let selectDateButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "날짜 선택"
        button.style = .plain
        
        return button
    }()
    
    let selectModeButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "화면 모드 변경"
        button.style = .plain
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureLayout()
        
        //loadingIndicatorView.startAnimating()
        configureRootView()
        configureNavigationController()
        configureToolBar()
        configureDataSource()
        configureCollectionView()
        configureRefreshControl()
        
        bind()
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
    
    func bind() {
        let willAppearView = self.rx.viewWillAppear.asObservable()
        let didModelSelected = collectionView.rx.modelSelected(DailyBoxOffice.self).asObservable()
        let didTapSelectDateButton = selectDateButton.rx.tap.asObservable()
        let didTapSelectModeButton = selectModeButton.rx.tap.asObservable()
        
        let input = MovieRankingViewModel.Input(willAppearView: willAppearView,
                                                didModelSelected: didModelSelected,
                                                didTapSelectDateButton: didTapSelectDateButton,
                                                didTapSelectModeButton: didTapSelectModeButton)
        let output = viewModel.transform(input)
        
        output.boxOffice
            .observe(on: MainScheduler.instance)
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.currentDate
            .observe(on: MainScheduler.instance)
            .map { $0.convertString(isFormatted: true)}
            .bind(to: rx.title)
            .disposed(by: disposeBag)
        
        output.detailMovieViewController
            .withUnretained(self)
            .subscribe { owner, detailMovieViewController in
                owner.navigationController?.pushViewController(detailMovieViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.calendarViewController
            .withUnretained(self)
            .subscribe { owner, calendarViewController in
                calendarViewController.delegate = owner
                owner.present(calendarViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.actionSheet
            .withUnretained(self)
            .subscribe { owner, actionSheet in
                actionSheet
                    .preferredStyle(.actionSheet)
                    .withTitle("화면모드 변경")
                    .addAction(owner.viewModel.cellMode.alertText,style: .default, handler: ({ _ in
                        owner.viewModel.changeCellMode()
                        owner.collectionView.reloadData()
                    }))
                    .addAction("취소", style: .cancel)
                    .show(in: owner)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
    }
    
    func configureDataSource() {
        dataSource = RxCollectionViewSectionedReloadDataSource<MovieRankingViewDataSection> { dataSource, tableView, indexPath, item in
            switch self.viewModel.cellMode {
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
    
    private func configureRootView() {
        view.backgroundColor = .white
        //self.title = viewModel.currentDate.value.convertString(isFormatted: true)
    }
    
    private func configureNavigationController() {
        self.navigationItem.rightBarButtonItem = selectDateButton
        self.navigationController?.isToolbarHidden = false
    }
    
    private func configureToolBar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [flexibleSpace, selectModeButton, flexibleSpace]
    }

    private func configureRefreshControl() {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self,
                                                 action: #selector(handleRefreshControl),
                                                 for: .valueChanged)
    }
    
    @objc private func handleRefreshControl() {
        configureRootView()
    }
}

extension MovieRankingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch viewModel.cellMode {
        case .list:
            return collectionViewWithList()
        case .icon:
            return collectionViewWithIcon(collectionViewLayout: collectionViewLayout)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard viewModel.cellMode == .icon else { return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) }
        
        return UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard viewModel.cellMode == .icon else { return 0 }
        
        return 15.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard viewModel.cellMode == .icon else { return 0 }
        
        return 10.0
    }
}

extension MovieRankingViewController: CalendarViewControllerDelegate {
    func deliverData(_ date: Date) {
        viewModel.updateDate(date)
        collectionView.reloadData()
    }
}


