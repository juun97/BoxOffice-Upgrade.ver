//
//  DetailMovieUseCase.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/08/16.
//

import Foundation
import RxSwift

enum DetailMovieUseCaseError: Error {
    case networkError(NetworkError)
    case decodeError
    case invalidRequest
}

protocol DetailMovieUseCaseType {
    func fetchMovieInformation(movieCode: String) -> Observable<DetailMovieInformation>
    func fetchMoviePoster(movieName: String) -> Observable<MoviePoster>
}

final class DetailMovieUseCase: DetailMovieUseCaseType {
    
    func fetchMovieInformation(movieCode: String) -> Observable<DetailMovieInformation> {
        guard let request = URLRequestMaker().makeMovieInformationURLRequest(movieCode: movieCode) else {
            return .error(DetailMovieUseCaseError.invalidRequest)
        }
        
        return NetworkManager.shared.fetchData(request: request)
            .decode(type: DetailMovieInformation.self, decoder: JSONDecoder())
    }
    
    func fetchMoviePoster(movieName: String) -> Observable<MoviePoster> {
        guard let request = URLRequestMaker().makeMoviePosterURLRequest(movieName: movieName) else {
            return .error(DetailMovieUseCaseError.invalidRequest)
        }
        
        return NetworkManager.shared.fetchData(request: request)
            .decode(type: MoviePoster.self, decoder: JSONDecoder())
        
    }
}
