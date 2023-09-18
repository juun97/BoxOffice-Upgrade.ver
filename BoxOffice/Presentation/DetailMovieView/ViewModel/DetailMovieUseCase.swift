//
//  DetailMovieUseCase.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/08/16.
//

import RxSwift

enum DetailMovieUseCaseError: Error {
    case networkError(NetworkError)
    case decodeError
    case invalidRequest
}

protocol DetailMovieUseCaseType {
    func fetchMovieInformation(movieCode: String) -> Observable<DetailMovieInformation>
    func fetchMoviePoster(movieName: String) -> Observable<MoviePoster>
    func fetchMoviePosterImageData(urlString: String?) -> Observable<Data>
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
    
    func fetchMoviePosterImageData(urlString: String?) -> Observable<Data> {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return .error(DetailMovieUseCaseError.invalidRequest)
        }
        
        return NetworkManager.shared.fetchData(request: URLRequest(url: url))
    }
}
