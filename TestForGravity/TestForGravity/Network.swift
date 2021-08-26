//
//  Network.swift
//  TestForGravity
//
//  Created by Анастасия Гаранович on 26.08.2021.
//

import UIKit

class Network {
    
    static let url = "https://2llctw8ia5.execute-api.us-west-1.amazonaws.com/prod"
    
    static func getGameStatusUrls(_ completion: @escaping (_ error: String?, _ data: GameStatusUrls?) -> ()) {
        
        guard let url = URL(string: url) else {
            completion("No url", nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(error.localizedDescription, nil)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion("No data received", nil)
                }
                return
            }
            
            let gameStatus = try? JSONDecoder().decode(GameStatusUrls.self, from: data)

            DispatchQueue.main.async {
                completion(nil, gameStatus)
            }
            
        }
        
        task.resume()
    }

}
