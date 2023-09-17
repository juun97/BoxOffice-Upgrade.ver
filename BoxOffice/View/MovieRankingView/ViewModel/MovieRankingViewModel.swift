//
//  MovieRankingViewModel.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/08/16.
//

import Foundation
import RxSwift
import RxCocoa

final class MovieRankingViewModel: NSObject, ViewModelType {
    typealias Input = MovieRankingViewInput
    typealias Output = MovieRankingViewOutput
    
    struct MovieRankingViewInput {
        let willAppearView: Observable<Bool>
        let didModelSelected: Observable<DailyBoxOffice>
        let didTapSelectDateButton: Observable<Void>
        let didTapSelectModeButton: Observable<Void>
    }
    
    struct MovieRankingViewOutput {
        let boxOffice: Observable<[MovieRankingViewDataSection]>
        let currentDate: Observable<Date>
        let detailMovieViewController: Observable<DetailMovieViewController>
        let calendarViewController: Observable<CalendarViewController>
        let actionSheet: Observable<AlertBuilder>
    }

    private let useCase: MovieRankingUseCaseType
    private var currentDate: BehaviorRelay<Date> = .init(value: .yesterday)
    var cellMode: CellMode {
        return useCase.readCellMode()
    }
    
    init(useCase: MovieRankingUseCaseType = MovieRankingUseCase()) {
        self.useCase = useCase
    }
    
    func transform(_ input: MovieRankingViewInput) -> MovieRankingViewOutput {
        let boxOffice = input.willAppearView
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.useCase.fetchBoxOfficeData(date: owner.currentDate.value)
            }
            .map { boxOfficeList in
                [MovieRankingViewDataSection(header: "main", items: boxOfficeList)]
            }
        
        let currentDate = input.willAppearView
            .withUnretained(self)
            .map { owner, _ in
                owner.currentDate.value
            }
        
        let detailMovieViewController = input.didModelSelected
            .withUnretained(self)
            .map { owner, model in
                DetailMovieViewController(movieCode: model.movieCode)
            }
        
        let calendarViewController = input.didTapSelectDateButton
            .withUnretained(self)
            .map { owner, _ in
                CalendarViewController(owner.currentDate.value)
            }
        
        let actionSheet = input.didTapSelectModeButton
            .withUnretained(self)
            .map { owner, _ in
                AlertBuilder()
            }
 
        return Output(boxOffice: boxOffice,
                      currentDate: currentDate,
                      detailMovieViewController: detailMovieViewController,
                      calendarViewController: calendarViewController,
                      actionSheet: actionSheet)
    }
    
    func changeCellMode() {
        switch cellMode {
        case .list:
            useCase.saveCellMode(.icon)
        case .icon:
            useCase.saveCellMode(.list)
        }
    }
    
    func updateDate(_ date: Date) {
        currentDate.accept(date)
    }
}

extension MovieRankingViewModel: CalendarViewControllerDelegate {
    func deliverData(_ data: Date) {
        updateDate(data)
    }
}
