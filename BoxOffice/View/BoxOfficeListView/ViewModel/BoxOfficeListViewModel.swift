//
//  BoxOfficeListViewModel.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/08/16.
//

import Foundation
import RxSwift
import RxCocoa

final class BoxOfficeListViewModel {
    
    private let useCase: BoxOfficeListUseCaseType
    private(set) var boxOffice: BoxOffice?
    private var currentDate: String = Date.yesterday.convertString(isFormatted: false)
    
    let _boxOffice2 = BehaviorRelay<[MainDataSection]>(value: [])
    
    var boxOffice2: Observable<[MainDataSection]> {
        return _boxOffice2.asObservable()
    }
    
    private func updateBoxOffice(newValue: [DailyBoxOffice]) {
        let dataSection = newValue.map{ _ in MainDataSection(header: "main", items: newValue) }
        _boxOffice2.accept(dataSection)
    }
    
    init(useCase: BoxOfficeListUseCaseType = BoxOfficeListUseCase()) {
        self.useCase = useCase
    }
    
    func fetchData() {
        useCase.fetchBoxOfficeData(dateString: currentDate)
            .subscribe(onSuccess: { boxOffice in
                self.updateBoxOffice(newValue: boxOffice.boxOfficeResult.dailyBoxOfficeList)
            }, onFailure: { error in
                
            })
            .dispose()
    }
}
