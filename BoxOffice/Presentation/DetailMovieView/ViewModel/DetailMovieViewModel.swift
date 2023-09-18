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
        let viewWillAppear: Observable<Void>
    }
    
    struct DetailMovieOutput {
        let movieInformation: Observable<DetailMovieInformation>
        let movieImageURL: Observable<MoviePoster>
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

        let moviePoster = movieInformation
            .withUnretained(self)
            .flatMap { owner, movie in
                owner.useCase.fetchMoviePoster(movieName: movie.movieInformationResult.movieInformation.movieName)
            }
            
        
        return Output(movieInformation: movieInformation, movieImageURL: moviePoster)
        
    }
}
