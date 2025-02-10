//
//  TransformedSchedule.swift
//  OrioksApp
//
//  Created by Y on 08.02.2025.
//

import Foundation

struct TransformedSchedule: Codable {
    let last_updated: String
    let semester: String
    let week_type: [String: [String: [String: LessonInfo]]]
}

struct LessonInfo: Codable {
    let classroom: String
    let name: String
    let TeacherFull: String
    let Teacher: String
    let type: String
    let time_start: String
    let time_end: String
}

func transformSchedule(from response: ScheduleResponse) -> TransformedSchedule {
    // Используем текущую дату для last_updated
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    let lastUpdated = dateFormatter.string(from: now)
    
    let semester = response.semestr
    
    // Создадим словарь для группировки по типу недели (используем DayNumber как ключ),
    // затем по дню (преобразуем числовой день в русское название) и затем по номеру пары (Time.Code).
    var weekTypeDict: [String: [String: [String: LessonInfo]]] = [:]
    
    // Функция для преобразования числового дня (1...6) в название
    func russianDayName(from day: Int) -> String {
        switch day {
        case 1: return "Понедельник"
        case 2: return "Вторник"
        case 3: return "Среда"
        case 4: return "Четверг"
        case 5: return "Пятница"
        case 6: return "Суббота"
        default: return "День \(day)"
        }
    }
    
    // Форматтер для времени (HH:mm)
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    
    // Проходим по каждому элементу расписания из Data
    for item in response.data {
        // Используем значение DayNumber как ключ для типа недели (например, "0", "1", ...)
        let weekTypeKey = String(item.dayNumber)
        // Преобразуем число дня в название (например, 1 -> "Понедельник")
        let dayKey = russianDayName(from: item.day)
        // Используем код пары как ключ (например, "1", "2", ...)
        let lessonKey = String(item.time.code)
        
        // Извлекаем тип пары из названия предмета – ищем текст в квадратных скобках в конце
        let className = item.classInfo.name
        var extractedType = ""
        if let start = className.lastIndex(of: "["), let end = className.lastIndex(of: "]"), start < end {
            extractedType = String(className[className.index(after: start)..<end])
        }
        
        let lessonInfo = LessonInfo(
            classroom: item.room.name,
            name: className,
            TeacherFull: item.classInfo.teacherFull,
            Teacher: item.classInfo.teacher,
            type: extractedType,
            time_start: timeFormatter.string(from: item.time.timeFrom),
            time_end: timeFormatter.string(from: item.time.timeTo)
        )
        
        // Если для данного типа недели ещё нет записи – создаём
        if weekTypeDict[weekTypeKey] == nil {
            weekTypeDict[weekTypeKey] = [:]
        }
        // Если для данного дня ещё нет записи – создаём
        if weekTypeDict[weekTypeKey]?[dayKey] == nil {
            weekTypeDict[weekTypeKey]?[dayKey] = [:]
        }
        // Сохраняем информацию о паре под ключом lessonKey
        weekTypeDict[weekTypeKey]?[dayKey]?[lessonKey] = lessonInfo
    }
    
    return TransformedSchedule(last_updated: lastUpdated, semester: semester, week_type: weekTypeDict)
}
