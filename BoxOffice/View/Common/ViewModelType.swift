//
//  ViewModelType.swift
//  BoxOffice
//
//  Created by 김성준 on 2023/09/12.
//

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
