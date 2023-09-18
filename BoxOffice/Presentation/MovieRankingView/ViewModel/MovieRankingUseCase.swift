//
//  MovieRankingUseCase.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/08/16.
//

import Foundation
import RxSwift

enum MovieRankingUseCaseError: Error {
    case networkError(NetworkError)
    case decodeError
    case invalidRequest
}

protocol MovieRankingUseCaseType {
    func fetchBoxOfficeData(date: Date) -> Observable<[DailyBoxOffice]>
    func readCellMode() -> CellMode
    func saveCellMode(_ cellMode: CellMode)
}

final class MovieRankingUseCase: MovieRankingUseCaseType {
    private let urlMaker = URLRequestMaker()
    
    func fetchBoxOfficeData(date: Date) -> Observable<[DailyBoxOffice]> {
        let dateString = date.convertString(isFormatted: false)
        
        guard let request = self.urlMaker.makeBoxOfficeURLRequest(date: dateString) else {
            return .error(MovieRankingUseCaseError.invalidRequest)
        }
        
        return NetworkManager.shared.fetchData(request: request)
            .decode(type: BoxOffice.self, decoder: JSONDecoder())
            .map { $0.boxOfficeResult.dailyBoxOfficeList }
    }
    
    func readCellMode() -> CellMode {
        guard let data = UserDefaults.standard.data(forKey: CellMode.identifier),
              let cellMode = try? DecodeManager().decodeJSON(data: data, type: CellMode.self) else {
            return .list
        }
        
        return cellMode
    }
    
    func saveCellMode(_ cellMode: CellMode) {
        let encoder = JSONEncoder()
        let encodedData = try? encoder.encode(cellMode)
        UserDefaults.standard.set(encodedData, forKey: CellMode.identifier)
    }
}
