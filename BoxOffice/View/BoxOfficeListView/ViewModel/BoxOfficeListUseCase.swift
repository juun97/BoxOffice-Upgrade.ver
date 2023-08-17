//
//  BoxOfficeListUseCase.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/08/16.
//

import Foundation
import RxSwift

protocol BoxOfficeListUseCaseType {
    func fetchBoxOfficeData(dateString: String) -> Single<BoxOffice>
}

final class BoxOfficeListUseCase: BoxOfficeListUseCaseType {
    
    private let networkManager = NetworkManager.shared
    private let decoder = DecodeManager()
    private let urlMaker = URLRequestMaker()
    private var currentDate: String = Date.yesterday.convertString(isFormatted: false)
    
    func fetchBoxOfficeData(dateString: String) -> Single<BoxOffice>  {
        return Single.create { observer in
            guard let request = self.urlMaker.makeBoxOfficeURLRequest(date: dateString) else {
                return Disposables.create()
            }
            
            self.networkManager.fetchData(request: request)
                .subscribe(onSuccess: { data in
                    let decodedData = DecodeManager().decodeJSON(data: data, type: BoxOffice.self)
                    
                    switch decodedData {
                    case .success(let boxOffice):
                        observer(.success(boxOffice))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                    
                }, onFailure: { error in
                    observer(.failure(error))
                })
                .dispose()
            
            return Disposables.create()
        }

        
    }
    
    
}
