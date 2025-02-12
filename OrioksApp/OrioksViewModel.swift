import Foundation
import Combine

class OrioksViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var token: String? = nil
    @Published var newSchedule: ScheduleResponse? = nil
    @Published var transformedSchedule: TransformedSchedule? = nil
    @Published var scheduleMeta: ScheduleMeta? = nil
    @Published var schedule: GroupSchedule? = nil
    @Published var errorMessage: String? = nil
    @Published var timetable: [String: [String]]? = nil
    @Published var groupId: String = ""
    @Published var studentInfo: Student? = nil
    @Published var currentWeek: Int = 0
    @Published var currentWeekType: Int = 0
    
    
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
                    //self.fetchGroupsAndSetGroupId(for: student.group)
                    print("Информация получена \(student.group)")
                    self.fetchNewSchedule()
                case .failure(let error):
                    print("Ошибка получения информации о студенте: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchScheduleMeta() {
        guard let token = token else { return }
        APIManager.getScheduleMeta(token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let meta):
                    self.scheduleMeta = meta
                    // Вычисляем текущую неделю и тип недели на основе meta.semester_start
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    if let semesterStartDate = formatter.date(from: meta.semester_start) {
                        let now = Date()
                        let days = Calendar.current.dateComponents([.day], from: semesterStartDate, to: now).day ?? 0
                        let week = ((days + 1) / 7) + 1
                        self.currentWeek = week
                        self.currentWeekType = (week - 1) % 4
                    }
                case .failure(let error):
                    self.errorMessage = "Ошибка получения мета расписания: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func fetchNewSchedule() {
        print("вызов fetchNewSchedule")
        guard let groupName = studentInfo?.group, !groupName.isEmpty else {
            self.errorMessage = "Информация о группе отсутствует"
            return
        }
        
        APIManager.getScheduleData(groupName: groupName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let scheduleResponse):
                    self.newSchedule = scheduleResponse
                    // Преобразуем расписание
                    self.transformedSchedule = transformSchedule(from: scheduleResponse)
                    self.fetchScheduleMeta()
                case .failure(let error):
                    self.errorMessage = "Ошибка получения расписания: \(error.localizedDescription)"
                }
            }
        }
    }    /*/// Запрашиваем список групп и сопоставляем имя студента с именем группы
    func fetchGroupsAndSetGroupId(for studentGroupName: String) {
        guard let token = token else { return }
        APIManager.getGroups(token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let groups):
                    // Сопоставляем группу, обрезая дополнительную информацию в скобках.
                    if let matchingGroup = groups.first(where: { group in
                        // Разделяем имя по строке " (" и берем первую часть
                        let trimmedName = group.name.components(separatedBy: " (").first ?? group.name
                        return trimmedName == studentGroupName
                    }) {
                        self.groupId = String(matchingGroup.id)
                        print("Информация получена \(self.groupId)")
                        self.fetchSchedule()
                    } else {
                        self.errorMessage = "Не найдена группа для студента: \(studentGroupName)"
                    }
                case .failure(let error):
                    self.errorMessage = "Ошибка получения списка групп: \(error.localizedDescription)"
                }
            }
        }
    }*/
    /*
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
    func fetchTimetable() {
        guard let token = token else { return }
        APIManager.getTimetable(token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let timetable):
                    self.timetable = timetable
                case .failure(let error):
                    self.errorMessage = "Ошибка получения таймтейбла: \(error.localizedDescription)"
                }
            }
        }
    }*/
}
