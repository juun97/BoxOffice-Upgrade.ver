//
//  DetailMovieViewController.swift
//  BoxOffice
//
//  Created by Rhode, Rilla on 2023/03/31.
//

import UIKit
import RxSwift

final class DetailMovieViewController: UIViewController {
    // MARK: - Property
    private let disposeBag = DisposeBag()
    private let viewModel: DetailMovieViewModel
    
    //MARK: - UIProperty
    private let loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .large)
        loadingIndicatorView.color = .systemGray3
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicatorView.hidesWhenStopped = true
        
        return loadingIndicatorView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollview
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let directorStackView = CustomStackView(title: "감독")
    private let productYearStackView = CustomStackView(title: "제작년도")
    private let openDateStackView = CustomStackView(title: "개봉일")
    private let showTimeStackView = CustomStackView(title: "상영시간")
    private let watchGradeStackView = CustomStackView(title: "관람등급")
    private let nationStackView = CustomStackView(title: "제작국가")
    private let genresStackView = CustomStackView(title: "장르")
    private let actorsStackView = CustomStackView(title: "배우")
    
    // MARK: - Method
    init(viewModel: DetailMovieViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        configureViewController()
        configureUI()
        configureLayout()
        bind()
    }
    
    private func bind() {
        let viewWillAppear = self.rx.viewWillAppear.asObservable()
        let input = DetailMovieViewModel.Input(viewWillAppear: viewWillAppear)
        let output = viewModel.transform(input)
        
        output.movieInformation
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe { owner, movie in
                let movieInfo = movie.movieInformationResult.movieInformation
                owner.configureContentStackView(movieInformation: movieInfo)
            }
            .disposed(by: disposeBag)
        
        output.movieImageData
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .map { owner, data in
                UIImage(data: data)
            }
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
    }

    private func configureViewController() {
        view.backgroundColor = .white
    }

    private func configureUI() {
        view.addSubview(scrollView)
        view.addSubview(loadingIndicatorView)
        scrollView.addSubview(contentStackView)
        
        [imageView, directorStackView, productYearStackView,
         openDateStackView, showTimeStackView, watchGradeStackView,
         nationStackView, genresStackView, actorsStackView].forEach { view in
            contentStackView.addArrangedSubview(view)
        }
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            loadingIndicatorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            loadingIndicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            
            imageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.6)
        ])
    }
    
    private func configureContentStackView(movieInformation: MovieInformation) {
        let director = movieInformation.directors.map(\.peopleName).joined(separator: ", ").formatEmptyString()
        let watchGrade = movieInformation.audits.map(\.watchGradeName).joined(separator: ", ").formatEmptyString()
        let nation = movieInformation.nations.map(\.nationName).joined(separator: ", ").formatEmptyString()
        let genre = movieInformation.genres.map(\.genreName).joined(separator: ", ").formatEmptyString()
        let actor = movieInformation.actors.map(\.peopleName).joined(separator: ", ").formatEmptyString()
        let productYear = movieInformation.productYear
        let openDate = movieInformation.openDate.formatDateString(format: DateFormat.yearMonthDay)
        let showTime = movieInformation.showTime
        
        directorStackView.configureContext(context: director)
        productYearStackView.configureContext(context: productYear)
        openDateStackView.configureContext(context: openDate)
        showTimeStackView.configureContext(context: showTime)
        watchGradeStackView.configureContext(context: watchGrade)
        nationStackView.configureContext(context: nation)
        genresStackView.configureContext(context: genre)
        actorsStackView.configureContext(context: actor)
    }
}
