//
//  DetailMovieViewModel.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/08/16.
//

import Foundation
import RxSwift

final class DetailMovieViewModel: ViewModelType {
    
    typealias Input = DetailMovieInput
    typealias Output = DetailMovieOutput
    
    struct DetailMovieInput {
        let viewWillAppear: Observable<Bool>
    }
    
    struct DetailMovieOutput {
        let movieInformation: Observable<DetailMovieInformation>
        let movieImageData: Observable<Data>
    }
    
    private let movieCode: String
    private let useCase: DetailMovieUseCaseType
    
    init(movieCode: String, useCase: DetailMovieUseCase = .init()) {
        self.movieCode = movieCode
        self.useCase = useCase
    }
    
    
    func transform(_ input: DetailMovieInput) -> DetailMovieOutput {
        let movieInformation = input.viewWillAppear
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.useCase.fetchMovieInformation(movieCode: owner.movieCode)
            }

        let movieImageData = movieInformation
            .withUnretained(self)
            .flatMap { owner, movie in
                owner.useCase.fetchMoviePoster(movieName: movie.movieInformationResult.movieInformation.movieName)
            }
            .withUnretained(self)
            .flatMap { owner, moviePoster in
                let url = moviePoster.documents[index: 0]?.imageURL
                return owner.useCase.fetchMoviePosterImageData(urlString: url)
            }
            
        
        return Output(movieInformation: movieInformation, movieImageData: movieImageData)
        
    }
}
