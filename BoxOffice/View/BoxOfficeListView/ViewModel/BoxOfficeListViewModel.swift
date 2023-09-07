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
    private var currentDate: String = Date.yesterday.convertString(isFormatted: false)
    private let disposeBag = DisposeBag()
    
    private let _boxOffice = BehaviorRelay<[MainDataSection]>(value: [])
    var boxOffice: Observable<[MainDataSection]> {
        return _boxOffice.asObservable()
    }
    
    let cellMode = BehaviorRelay<CellMode>(value: .list)
    
    init(useCase: BoxOfficeListUseCaseType = BoxOfficeListUseCase()) {
        self.useCase = useCase
    }
    
    func fetchData() {
        useCase.fetchBoxOfficeData(dateString: currentDate)
            .subscribe(onNext: { boxOfficeList in
                self.updateBoxOffice(newValue: boxOfficeList)
            }, onError: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func readCellMode() {
        let cellMode = useCase.readCellMode()
        updateCellMode(newValue: cellMode)
    }
    
    func changeCellMode() {
        switch cellMode.value {
        case .list:
            cellMode.accept(.icon)
        case .icon:
            cellMode.accept(.list)
        }
        
        useCase.saveCellMode(cellMode.value)
    }
    
    private func updateBoxOffice(newValue: [DailyBoxOffice]) {
        let dataSection =  MainDataSection(header: "main", items: newValue)
        _boxOffice.accept([dataSection])
    }
    
    private func updateCellMode(newValue: CellMode) {
        cellMode.accept(newValue)
    }
    
}
