//
//  WebServices.swift
//  AppointmentManager
//
//  Created by Vishal Bavaliya on 03/08/22.
//

import Foundation

class WebServices {
    
    func requestGetURL(enterURL: String,
                       success: @escaping (JSONDecoder, Data) -> Void,
                       failure: @escaping (Error) -> Void) {
        
        let urlRequest = URLRequest(url: URL(string: enterURL)!)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { data, response, error in
            
            let decoder = JSONDecoder()
            do {
                success(decoder, data!)
            } catch {
                failure(error)
            }
        }
        task.resume()
    }
}
