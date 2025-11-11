//
//  NetworkMqttSender.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/10.
//

import Foundation

/// 網路錯誤類型定義
enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case serverError(Int)
    case unknown(Error)
}

/// 通用的網路工具
final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "http://localhost:8000"
    
//    // MARK: - 通用 GET 方法
//    func get<T: Decodable>(
//        path: String,
//        queryItems: [URLQueryItem]? = nil,
//        completion: @escaping (Result<T, NetworkError>) -> Void
//    ) {
//        var components = URLComponents(string: baseURL + path)
//        components?.queryItems = queryItems
//        
//        guard let url = components?.url else {
//            completion(.failure(.invalidURL))
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.timeoutInterval = 15
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            self.handleResponse(data: data, response: response, error: error, completion: completion)
//        }.resume()
//    }
    
    // MARK: - 通用 POST 方法
    func post<T: Decodable, Body: Encodable>(
        path: String,
        body: Body,
        completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: baseURL + path) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.unknown(error)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }.resume()
    }
    
    // MARK: - 通用回應處理
    private func handleResponse<T: Decodable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(.unknown(error)))
            }
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                completion(.failure(.requestFailed))
            }
            return
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            DispatchQueue.main.async {
                completion(.failure(.serverError(httpResponse.statusCode)))
            }
            return
        }
        
        guard let data = data else {
            DispatchQueue.main.async {
                completion(.failure(.requestFailed))
            }
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            DispatchQueue.main.async {
                completion(.success(decoded))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(.decodingFailed))
            }
        }
    }
}
