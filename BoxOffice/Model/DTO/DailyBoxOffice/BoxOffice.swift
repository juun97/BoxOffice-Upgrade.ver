//
//  BoxOffice.swift
//  BoxOffice
//
//  Created by Rhode, Rilla on 2023/03/20.
//

import Foundation

struct BoxOffice: Decodable {
    var id = UUID()
    let boxOfficeResult: BoxOfficeResult
    
    private enum CodingKeys: String, CodingKey {
        case boxOfficeResult
    }

}
