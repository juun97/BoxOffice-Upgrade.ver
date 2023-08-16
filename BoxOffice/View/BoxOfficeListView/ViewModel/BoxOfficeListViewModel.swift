//
//  BoxOfficeListViewModel.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/08/16.
//

import Foundation

final class BoxOfficeListViewModel {
    
    private let useCase: BoxOfficeListUseCaseType
    
    init(useCase: BoxOfficeListUseCaseType = BoxOfficeListUseCase()) {
        self.useCase = useCase
    }
}
