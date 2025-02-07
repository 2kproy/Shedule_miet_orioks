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

func transformSchedule(from items: [ScheduleItem]) -> GroupSchedule {
    // Массив с названиями дней недели (английскими именами в нижнем регистре)
    let dayNames = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
    
    // Результирующий словарь: ключ – номер недели (например, "0" или "1"),
    // значение – словарь, где ключ – день недели, затем словарь с номером пары и ClassInfo
    var weeks: [String: [String: [String: ClassInfo]]] = [:]
    
    for item in items {
        // Используем значение поля week как ключ (приводим к строке)
        let weekKey = String(item.week)
        
        // Проверяем, что значение day попадает в диапазон [0..<dayNames.count]
        guard item.day >= 0, item.day < dayNames.count else {
            print("Неверное значение day: \(item.day)")
            continue
        }
        let dayName = dayNames[item.day]
        
        // Ключ для пары – значение lesson как строка
        let lessonKey = String(item.lesson)
        
        // Создаём объект ClassInfo на основе ScheduleItem
        let classInfo = ClassInfo(
            classroom: item.location,
            name: item.name,
            teacher: item.teacher,
            teacher_initials: "",  // Здесь можно реализовать вычисление инициалов при необходимости
            type: item.type
        )
        
        // Если для недели ещё нет записи, создаём словарь
        if weeks[weekKey] == nil {
            weeks[weekKey] = [:]
        }
        // Если для данного дня недели ещё нет записи, создаём словарь
        if weeks[weekKey]?[dayName] == nil {
            weeks[weekKey]?[dayName] = [:]
        }
        // Сохраняем classInfo по номеру пары
        weeks[weekKey]?[dayName]?[lessonKey] = classInfo
    }
    
    // Для полей lastUpdated и semester можно использовать текущую дату или значения по умолчанию.
    // Например, используем ISO8601 строку текущего момента и пустую строку для семестра.
    let now = ISO8601DateFormatter().string(from: Date())
    
    return GroupSchedule(lastUpdated: now, semester: "", weeks: weeks)
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
    /// Запрос времени начала и конца всех пар
    static func getTimetable(token: String, completion: @escaping (Result<[String: [String]], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/schedule/timetable") else {
            print("Ошибка: Неверный URL для таймтейбла")
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
                print("Ошибка запроса таймтейбла: \(error)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Некорректный ответ от сервера (таймтейбл)")
                completion(.failure(APIError.invalidResponse))
                return
            }
            print("HTTP статус (таймтейбл): \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                print("Ошибка HTTP кода (таймтейбл): \(httpResponse.statusCode)")
                completion(.failure(APIError.httpError(code: httpResponse.statusCode)))
                return
            }
            do {
                let timetable = try JSONDecoder().decode([String: [String]].self, from: data)
                print("Получен таймтейбл: \(timetable)")
                completion(.success(timetable))
            } catch {
                print("Ошибка декодирования таймтейбла: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    /// Запрос расписания для конкретной группы
//    static func getSchedule(token: String, groupId: String, completion: @escaping (Result<GroupSchedule, Error>) -> Void) {
//        guard let url = URL(string: "\(baseURL)/api/v1/schedule/groups/\(groupId)") else {
//            completion(.failure(APIError.invalidURL))
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        let userAgent = "orioks_api_test/0.1 iOS \(UIDevice.current.systemVersion)"
//        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let httpResponse = response as? HTTPURLResponse else {
//                completion(.failure(APIError.invalidResponse))
//                return
//            }
//            guard (200...299).contains(httpResponse.statusCode), let data = data else {
//                completion(.failure(APIError.httpError(code: httpResponse.statusCode)))
//                return
//            }
//            do {
//                let scheduleResponse = try JSONDecoder().decode(GroupSchedule.self, from: data)
//                completion(.success(scheduleResponse))
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume()
//    }
    static func getSchedule(token: String, groupId: String, completion: @escaping (Result<GroupSchedule, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/schedule/groups/\(groupId)") else {
            print("Ошибка: Неверный URL")
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
                print("Ошибка запроса расписания: \(error)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Некорректный ответ от сервера")
                completion(.failure(APIError.invalidResponse))
                return
            }
            print("HTTP статус: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                print("Ошибка HTTP кода: \(httpResponse.statusCode)")
                completion(.failure(APIError.httpError(code: httpResponse.statusCode)))
                return
            }
            
            // Вывод полученных данных для отладки
            if let jsonStr = String(data: data, encoding: .utf8) {
                print("Полученные данные расписания: \(jsonStr)")
            }
            
            do {
                // Декодируем JSON как массив ScheduleItem
                let items = try JSONDecoder().decode([ScheduleItem].self, from: data)
                // Преобразуем массив в структуру GroupSchedule
                let schedule = transformSchedule(from: items)
                print("Успешно получено расписание")
                completion(.success(schedule))
            } catch {
                print("Ошибка декодирования расписания: \(error)")
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
