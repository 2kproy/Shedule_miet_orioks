import Foundation

// MARK: - Модели данных

/// Модель информации о студенте
struct Student: Codable {
    let course: Int
    let department: String
    let full_name: String
    let group: String
    let record_book_id: Int
    let semester: Int
    let study_direction: String
    let study_profile: String
    let year: String
}

/// Модель информации о группе, получаемая из API /api/v1/schedule/groups
struct GroupInfo: Codable, Identifiable {
    let id: Int
    let name: String
}

/// Ответ авторизации (токен)
struct AuthResponse: Codable {
    let token: String
}

/// Информация о конкретной паре (занятии)
struct ClassInfo: Codable, Identifiable {
    var id: String { UUID().uuidString }
    let classroom: String
    let name: String
    let teacher: String
    let teacher_initials: String
    let type: String
}

/// Структура расписания группы.
struct GroupSchedule: Codable {
    let lastUpdated: String
    let semester: String
    /// Ключ – номер недели, значение – расписание по дням недели.
    let weeks: [String: [String: [String: ClassInfo]]]
    
    private enum CodingKeys: String, CodingKey {
        case last_updated, semester
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lastUpdated = try container.decode(String.self, forKey: .last_updated)
        semester = try container.decode(String.self, forKey: .semester)
        
        // Динамическое декодирование остальных ключей как недель
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var weeksDict = [String: [String: [String: ClassInfo]]]()
        for key in dynamicContainer.allKeys {
            if key.stringValue == "last_updated" || key.stringValue == "semester" {
                continue
            }
            let weekData = try dynamicContainer.decode([String: [String: ClassInfo]].self, forKey: key)
            weeksDict[key.stringValue] = weekData
        }
        self.weeks = weeksDict
    }
    
    // Реализация метода encode(to:) для поддержки Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        // Сохраняем стандартные ключи
        let lastUpdatedKey = DynamicCodingKeys(stringValue: "last_updated")!
        try container.encode(lastUpdated, forKey: lastUpdatedKey)
        let semesterKey = DynamicCodingKeys(stringValue: "semester")!
        try container.encode(semester, forKey: semesterKey)
        
        // Сохраняем динамический контент расписания
        for (weekKey, days) in weeks {
            let key = DynamicCodingKeys(stringValue: weekKey)!
            try container.encode(days, forKey: key)
        }
    }
}

/// Для декодирования/кодирования ключей, неизвестных заранее.
struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) { self.stringValue = stringValue }
    
    var intValue: Int?
    init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
}
