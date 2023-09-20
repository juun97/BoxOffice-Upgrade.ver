//
//  MovieRankingViewModel.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/08/16.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

final class MovieRankingViewModel: ViewModelType {
    typealias Input = MovieRankingViewInput
    typealias Output = MovieRankingViewOutput
    
    struct MovieRankingViewInput {
        let viewWillAppear: Observable<Bool>
        let didModelSelected: Observable<DailyBoxOffice>
        let didTapSelectDateButton: Observable<Void>
        let didTapSelectModeButton: Observable<Void>
        let didCalendarViewDismiss: Observable<Notification>
    }
    
    struct MovieRankingViewOutput {
        let boxOffice: Observable<[MovieRankingViewDataSection]>
        let currentDate: Observable<Date>
        let detailMovieViewController: Observable<DetailMovieViewController>
        let calendarViewController: Observable<Date>
        let alertBuilder: Observable<AlertBuilder>
    }
    
    private let useCase: MovieRankingUseCaseType
    private var currentDate: Date = .yesterday
    
    var cellMode: CellMode {
        return useCase.readCellMode()
    }
    
    init(useCase: MovieRankingUseCaseType = MovieRankingUseCase()) {
        self.useCase = useCase
    }
    
    func transform(_ input: MovieRankingViewInput) -> MovieRankingViewOutput {
        let initialDate = input.viewWillAppear
            .map { _ in
                self.currentDate
            }
        
        let updatedDate = input.didCalendarViewDismiss
            .compactMap { notification in
                notification.userInfo?["currentDate"] as? Date
            }
            .withUnretained(self)
            .map { owner, date in
                owner.currentDate = date
            }
            .withUnretained(self)
            .map { owner, _ in
                owner.currentDate
            }
   
        
        let currentDate = Observable.of(initialDate, updatedDate).merge()
        
        let boxOffice = currentDate
            .withUnretained(self)
            .flatMap { owner, date in
                owner.useCase.fetchBoxOfficeData(date: date)
            }
            .map { boxOfficeList in
                [MovieRankingViewDataSection(header: "main", items: boxOfficeList)]
            }
        
        let detailMovieViewController = input.didModelSelected
            .withUnretained(self)
            .map { owner, model in
                DetailMovieViewController(viewModel: .init(movieCode: model.movieCode))
            }
        
        let calendarViewController = input.didTapSelectDateButton
            .withUnretained(self)
            .map { owner, date in
                owner.currentDate
            }
//            .map { owner, _ in
//                print("ggg")
//            }
//            .flatMap { owner, _ in
//                currentDate
//            }
//            .map { date in
//                CalendarViewController(date)
//            }
            
        let alertBuilder = input.didTapSelectModeButton
            .map(AlertBuilder.init)
        
        
        return Output(boxOffice: boxOffice,
                      currentDate: currentDate,
                      detailMovieViewController: detailMovieViewController,
                      calendarViewController: calendarViewController,
                      alertBuilder: alertBuilder)
    }
    
    func changeCellMode() {
        switch cellMode {
        case .list:
            useCase.saveCellMode(.icon)
        case .icon:
            useCase.saveCellMode(.list)
        }
    }
}
