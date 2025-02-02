import Foundation
import Combine

class OrioksViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var token: String? = nil
    @Published var schedule: GroupSchedule? = nil
    @Published var errorMessage: String? = nil
    // groupId будет установлен после сопоставления информации о студенте и списка групп
    @Published var groupId: String = ""
    // Новое свойство для хранения информации о студенте
    @Published var studentInfo: Student? = nil
    
    init() {
        // При запуске пытаемся загрузить токен из Keychain
        if let tokenData = KeychainHelper.standard.read(service: "com.orioks.app", account: "userToken"),
           let storedToken = String(data: tokenData, encoding: .utf8) {
            self.token = storedToken
            self.isAuthenticated = true
            self.fetchStudentInfo()
        }
    }
    
    func login(username: String, password: String) {
        APIManager.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self.token = token
                    self.isAuthenticated = true
                    if let tokenData = token.data(using: .utf8) {
                        KeychainHelper.standard.save(tokenData, service: "com.orioks.app", account: "userToken")
                    }
                    self.fetchStudentInfo()
                case .failure(let error):
                    self.errorMessage = "Ошибка авторизации: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Авторизация по токену
    func tokenLogin(token: String) {
        self.token = token
        self.isAuthenticated = true
        if let tokenData = token.data(using: .utf8) {
            KeychainHelper.standard.save(tokenData, service: "com.orioks.app", account: "userToken")
        }
        self.fetchStudentInfo()
    }
    
    /// Запрос информации о студенте
    func fetchStudentInfo() {
        guard let token = token else { return }
        APIManager.getStudentInfo(token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let student):
                    self.studentInfo = student
                    // Далее сопоставляем группу (используя student.group)
                    self.fetchGroupsAndSetGroupId(for: student.group)
                    self.errorMessage = "Информация получена"
                case .failure(let error):
                    self.errorMessage = "Ошибка получения информации о студенте: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Запрашиваем список групп и сопоставляем имя студента с именем группы
    func fetchGroupsAndSetGroupId(for studentGroupName: String) {
        guard let token = token else { return }
        APIManager.getGroups(token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let groups):
                    if let matchingGroup = groups.first(where: { $0.name.contains(studentGroupName) || $0.name == studentGroupName }) {
                        self.groupId = matchingGroup.id
                        self.fetchSchedule()
                    } else {
                        self.errorMessage = "Не найдена группа для студента: \(studentGroupName)"
                    }
                case .failure(let error):
                    self.errorMessage = "Ошибка получения списка групп: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func fetchSchedule() {
        guard let token = token, !groupId.isEmpty else { return }
        APIManager.getSchedule(token: token, groupId: groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let schedule):
                    self.schedule = schedule
                case .failure(let error):
                    self.errorMessage = "Ошибка получения расписания: \(error.localizedDescription)"
                }
            }
        }
    }
}
