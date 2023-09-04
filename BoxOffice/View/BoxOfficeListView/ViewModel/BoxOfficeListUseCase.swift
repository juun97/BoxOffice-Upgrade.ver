//
//  BoxOfficeListUseCase.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/08/16.
//

import Foundation
import RxSwift

enum BoxOfficeListUseCaseError: Error {
    case networkError(NetworkError)
    case decodeError
    case invalidRequest
}

protocol BoxOfficeListUseCaseType {
    func fetchBoxOfficeData(dateString: String) -> Observable<[DailyBoxOffice]>
}

final class BoxOfficeListUseCase: BoxOfficeListUseCaseType {
    private let urlMaker = URLRequestMaker()

    func fetchBoxOfficeData(dateString: String) -> Observable<[DailyBoxOffice]> {
        guard let request = self.urlMaker.makeBoxOfficeURLRequest(date: dateString) else {
            return .error(BoxOfficeListUseCaseError.invalidRequest)
        }
        
        return NetworkManager.shared.fetchData(request: request)
            .decode(type: BoxOffice.self, decoder: JSONDecoder())
            .map { $0.boxOfficeResult.dailyBoxOfficeList }
    }
}

