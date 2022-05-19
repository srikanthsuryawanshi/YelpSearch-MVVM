//
//  ServiceProvider.swift
//  YelpSearch
//
//  Created by Srikanth SP on 23/03/22.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}

class ServiceProvider<T: Service> {
    var urlSession = URLSession.shared
    
    init() { }
    
    func load(service: T, completion: @escaping (Result<Data>) -> Void) {
        call(service.urlRequest, completion: completion)
    }
    
    func load<U>(service: T, decodeType: U.Type, completion: @escaping (Result<U>) -> Void) where U: Decodable {
        call(service.urlRequest) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let resp = try decoder.decode(decodeType, from: data)
                    completion(.success(resp))
                    print(resp)
                }
                catch DecodingError.dataCorrupted(let context) {
                    print(context)
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.valueNotFound(let value, let context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                }
                catch let err {
                    print(err.localizedDescription)
                    completion(.failure(err))
                }
            case .failure(let error):
                completion(.failure(error))
                
            }
        }
    }
}

extension ServiceProvider {
    private func call(_ request: URLRequest, deliverQueue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<Data>) -> Void) {
        urlSession.dataTask(with: request) { (data, _, error) in
            if let error = error {
                deliverQueue.async {
                    completion(.failure(error))
                }
            } else if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    }
                } catch let parseError {
                    print("parsing error: \(parseError)")
                    let outputStr  = String(data: data, encoding: String.Encoding.utf8)
                    print("parsing result data: \(outputStr)")
                    completion(.failure(parseError))

                }
                
                deliverQueue.async {
                    completion(.success(data))
                }
            }
        }.resume()
    }
}
