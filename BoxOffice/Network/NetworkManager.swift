//
//  NetworkManager.swift
//  BoxOffice
//
//  Created by Rhode, Rilla on 2023/03/21.
//

import Foundation
import RxSwift

final class NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    
    init(session: URLSession = URLSession.customCacheShared) {
        self.session = session
    }
    
    func startLoad(request: URLRequest, mime: String, complete: @escaping (Result<Data, NetworkError>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                complete(.failure(.responseError(error: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                complete(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                complete(.failure(.responseCodeError))
                return
            }
            
            let mimeType = response?.mimeType
            
            guard ((mimeType?.lowercased().contains(mime)) != nil) else {
                complete(.failure(.invalidMimeType))
                return
            }
            
            guard let validData = data else {
                complete(.failure(.noData))
                return
            }
            
            complete(.success(validData))
        }.resume()
    }
    
    func fetchData(request: URLRequest) -> Single<Data> {
        return Single.create { single in
            let task = self.session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    single(.failure(NetworkError.invalidResponse))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    single(.failure(NetworkError.responseCodeError))
                    return
                }
                
                guard let data = data else {
                    single(.failure(NetworkError.noData))
                    return
                }
                
                single(.success(data))
            }
            task.resume()
            
            return Disposables.create { task.cancel() }
        }
        
    }
}
