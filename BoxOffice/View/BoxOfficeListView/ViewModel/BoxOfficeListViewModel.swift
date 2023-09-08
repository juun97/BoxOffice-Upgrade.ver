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
    private let disposeBag: DisposeBag = .init()
    private let useCase: BoxOfficeListUseCaseType
    
    var currentDate: BehaviorRelay<Date> = .init(value: .yesterday)
    private let _boxOffice: BehaviorRelay<[MainDataSection]> = .init(value: [])
    var boxOffice: Observable<[MainDataSection]> {
        return _boxOffice.asObservable()
    }
    
    var cellMode: CellMode {
        return useCase.readCellMode()
    }
    
    init(useCase: BoxOfficeListUseCaseType = BoxOfficeListUseCase()) {
        self.useCase = useCase
    }
    
    func fetchData() {
        useCase.fetchBoxOfficeData(date: currentDate.value)
            .subscribe(onNext: { boxOfficeList in
                self.updateBoxOffice(newValue: boxOfficeList)
            }, onError: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
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
    
    private func updateBoxOffice(newValue: [DailyBoxOffice]) {
        let dataSection =  MainDataSection(header: "main", items: newValue)
        _boxOffice.accept([dataSection])
    }
}
