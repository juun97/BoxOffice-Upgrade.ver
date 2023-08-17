//
//  BoxOfficeListViewModel.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/08/16.
//

import Foundation

final class BoxOfficeListViewModel {
    
    private let useCase: BoxOfficeListUseCaseType
    private(set) var boxOffice: BoxOffice?
    private var currentDate: String = Date.yesterday.convertString(isFormatted: false)
    
    init(useCase: BoxOfficeListUseCaseType = BoxOfficeListUseCase()) {
        self.useCase = useCase
    }
    
    func fetchData() {
        useCase.fetchBoxOfficeData(dateString: currentDate)
            .subscribe(onSuccess: { boxOffice in
                self.boxOffice = boxOffice
            }, onFailure: { error in
                
            })
            .dispose()
    }
}
