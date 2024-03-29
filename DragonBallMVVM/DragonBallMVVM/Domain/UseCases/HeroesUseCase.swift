//
//  HeroesUseCase.swift
//  DragonBallMVVM
//
//  Created by Jose Bueno Cruz on 27/1/24.
//

import Foundation

// MARK: - Protocol
protocol HeroesUseCaseProtocol {
    func getHeros(name: String,
                  onSuccess: @escaping ([ModelDragonBall]) -> Void,
                  onError: @escaping (NetworkError) -> Void)
}

final class HeroesUseCase: HeroesUseCaseProtocol {
    
    // MARK: - Client
    private let client: APIClientProtocol
    
    // MARK: - Inits
    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }
    
    // MARK: - Methods
    func getHeros(name: String,
                  onSuccess: @escaping ([ModelDragonBall]) -> Void,
                  onError: @escaping (NetworkError) -> Void) {
        
        guard let url = URL(string: "\(EndPoints.url.rawValue)\(EndPoints.allHeros.rawValue)") else {
            onError(.malformeUrl)
            return
        }
        guard let token = UserDefaultsHelper.getToken() else {
            onError(.tokenFormatError)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethods.post
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue(HTTPMethods.contenType, forHTTPHeaderField: "Content-Type")
        
        struct HeroRequest: Codable {
            let name: String
        }
        
        let heroRequest = HeroRequest(name: name)
        urlRequest.httpBody = try? JSONEncoder().encode(heroRequest)
        
        client.request(urlRequest, using: [ModelDragonBall].self) { result in
            switch result {
            case let .success(dataHeroes):
                onSuccess(dataHeroes)
            case let .failure(error):
                onError(error)
            }
        }
    }
}

