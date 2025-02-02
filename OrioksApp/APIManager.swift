import Foundation
import UIKit

enum APIError: Error {
    case invalidURL
    case encodingError
    case invalidResponse
    case httpError(code: Int)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .encodingError:
            return "Ошибка кодирования"
        case .invalidResponse:
            return "Некорректный ответ от сервера"
        case .httpError(let code):
            return "HTTP ошибка с кодом \(code)"
        }
    }
}

struct APIManager {
    // Базовый URL изменён на требуемый адрес
    static let baseURL = "https://orioks.miet.ru"
    
    /// Запрос авторизации (получение токена)
    static func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/auth") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            completion(.failure(APIError.encodingError))
            return
        }
        let base64Login = loginData.base64EncodedString()
        request.addValue("Basic \(base64Login)", forHTTPHeaderField: "Authorization")
        
        let userAgent = "orioks_api_test/0.1 iOS \(UIDevice.current.systemVersion)"
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                completion(.failure(APIError.httpError(code: httpResponse.statusCode)))
                return
            }
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                completion(.success(authResponse.token))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Запрос информации о студенте
    static func getStudentInfo(token: String, completion: @escaping (Result<Student, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/student") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let userAgent = "orioks_api_test/0.1 iOS \(UIDevice.current.systemVersion)"
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                completion(.failure(APIError.httpError(code: httpResponse.statusCode)))
                return
            }
            do {
                let studentInfo = try JSONDecoder().decode(Student.self, from: data)
                completion(.success(studentInfo))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Запрос расписания для конкретной группы
    static func getSchedule(token: String, groupId: String, completion: @escaping (Result<GroupSchedule, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/schedule/groups/\(groupId)") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let userAgent = "orioks_api_test/0.1 iOS \(UIDevice.current.systemVersion)"
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                completion(.failure(APIError.httpError(code: httpResponse.statusCode)))
                return
            }
            do {
                let scheduleResponse = try JSONDecoder().decode(GroupSchedule.self, from: data)
                completion(.success(scheduleResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Запрос списка групп
    static func getGroups(token: String, completion: @escaping (Result<[GroupInfo], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/schedule/groups") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let userAgent = "orioks_api_test/0.1 iOS \(UIDevice.current.systemVersion)"
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                completion(.failure(APIError.httpError(code: httpResponse.statusCode)))
                return
            }
            do {
                let groups = try JSONDecoder().decode([GroupInfo].self, from: data)
                completion(.success(groups))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
