import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var viewModel: OrioksViewModel
    
    // Массив дней недели в нужном порядке
    private let daysArray = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]
    
    private var validDays: [String] {
            let calendar = Calendar.current
            let today = Date()
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today)!
            let todayWeekday = calendar.component(.weekday, from: today)
            if todayWeekday == 1 {
                return daysArray
            } else {
                return daysArray.filter { day in
                    if let d = nextDate(forDay: day) {
                        return d >= today && d < weekInterval.end
                    }
                    return false
                }
            }
        }
    
    var body: some View {
        NavigationStack {
            Group {
                if let ts = viewModel.transformedSchedule,
                   let weekSchedule = ts.week_type[String(viewModel.currentWeekType)] {  // показываем расписание для текущего типа недели
                    ScrollView {
                        VStack(spacing: 16) {
                            /// Верхняя часть
                            HStack(spacing: 16) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.systemGray6))
                                    .frame(width: 140, height: 40)
                                    .overlay(
                                        Text(viewModel.studentInfo?.group ?? "Группа")
                                            .font(.subheadline)
                                    )
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.systemGray6))
                                    .frame(width: 140, height: 40)
                                    .overlay(
                                        Text(weekTypeText(for: viewModel.currentWeekType))
                                            .font(.subheadline)
                                    )                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            
                            // Основной список расписания, сгруппированный по дням
                            ForEach(validDays, id: \.self) { day in
                                if let lessons = weekSchedule[day] {
                                    // В заголовке выводим название дня и соответствующую дату
                                    if let dateForDay = nextDate(forDay: day) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("\(day.uppercased()) | \(formattedDate(dateForDay))")
                                                .foregroundColor(.gray)
                                                .font(.headline)
                                                .bold()
                                                .padding(.leading, 8)
                                            VStack(spacing: 4) {
                                                ForEach(lessons.keys.sorted(), id: \.self) { lessonNumber in
                                                    if let lesson = lessons[lessonNumber] {
                                                        let isToday = Calendar.current.isDate(dateForDay, inSameDayAs: Date())
                                                        ClassRowView(lessonNumber: lessonNumber, lesson: lesson, isToday: isToday)
                                                                        }
                                                    // Добавляем Divider между парами, но не после последнего
                                                    if lessonNumber != lessons.keys.sorted().last {
                                                        Divider()
                                                            .background(Color(UIColor.systemGray5))
                                                            .padding(.horizontal, 16)
                                                    }
                                                }
                                            }
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 24)
                                                            .fill(Color(UIColor.systemGray6)))
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                    .navigationTitle("Расписание")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                viewModel.fetchNewSchedule()
                            }) {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        ProgressView("Загрузка расписания...")
                        Spacer()
                    }
                    .navigationTitle("Расписание")
                }
            }
        }
    }
    func weekTypeText(for weekType: Int) -> String {
        switch weekType {
        case 0:
            return "1-й Числитель"
        case 1:
            return "1-й Знаменатель"
        case 2:
            return "2-й Числитель"
        case 3:
            return "2-й Знаменатель"
        default:
            return ""
        }
    }
    // Вычисление дат
    private func nextDate(forDay day: String) -> Date? {
        // Соответствие: "Понедельник" -> 2, "Вторник" -> 3, ..., "Суббота" -> 7
        guard let index = daysArray.firstIndex(of: day) else { return nil }
        let desiredWeekday = index + 2
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.weekday], from: today)
        if let weekday = components.weekday, weekday == desiredWeekday {
            return today
        } else {
            return calendar.nextDate(after: today, matching: DateComponents(weekday: desiredWeekday), matchingPolicy: .nextTime)
        }
    }
    
    // Форматирует дату в строку, например "dd MMM" (например, "17 июл")
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
}

struct ClassRowView: View {
    @EnvironmentObject var viewModel: OrioksViewModel
    let lessonNumber: String
    let lesson: LessonInfo
    let isToday: Bool
    
    var body: some View {
        HStack {
            // левая колонка: информация о паре на скругленной плашке
            VStack(alignment: .leading, spacing: 4) {
//                Text("Пара \(lessonNumber)")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
                Text(lesson.name)
                    .font(.headline)
                Text("Кабинет: \(lesson.classroom)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Преподаватель: \(lesson.Teacher)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
//                Text("Тип пары: \(lesson.type)")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
            }
            Spacer()
           
            Text("\(lessonNumber)")
                .font(.system(size: 100, weight: .bold, design: .default))
                .foregroundColor(Color(UIColor.systemGray5))
                .offset(x: 0, y: 0)
            // правая колонка: отображение времени с заполненной полоской
            VStack {
                Text(lesson.time_start)
                    .font(.caption)
                ProgressBar(progress: progressFraction())
                    .frame(width: 4, height: 50)
                Text(lesson.time_end)
                    .font(.caption)
            }
            //.padding()
            //.background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.systemGray4)))
        }
        .frame(maxWidth: .infinity)
        //.padding(.vertical, 0)
    }
    
    /// Функция рассчитывает прогресс пары на основе времени начала и окончания.
    func progressFraction() -> Double {
        if !isToday {
            return 0.0
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        // Парсим время начала и окончания как даты (с референсным днем)
        guard let startTime = formatter.date(from: lesson.time_start),
              let endTime = formatter.date(from: lesson.time_end) else {
            return 0.0
        }
        
        let calendar = Calendar.current
        let now = Date()
        // Получаем компоненты сегодняшней даты
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        // Получаем часы и минуты из распарсенных дат
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        // Собираем новую дату для времени начала с сегодняшней датой
        var startDateComponents = DateComponents()
        startDateComponents.year = todayComponents.year
        startDateComponents.month = todayComponents.month
        startDateComponents.day = todayComponents.day
        startDateComponents.hour = startComponents.hour
        startDateComponents.minute = startComponents.minute
        
        // То же для времени окончания
        var endDateComponents = DateComponents()
        endDateComponents.year = todayComponents.year
        endDateComponents.month = todayComponents.month
        endDateComponents.day = todayComponents.day
        endDateComponents.hour = endComponents.hour
        endDateComponents.minute = endComponents.minute
        
        guard let startDate = calendar.date(from: startDateComponents),
              let endDate = calendar.date(from: endDateComponents) else {
            return 0.0
        }
        
        if now < startDate {
            return 0.0
        } else if now > endDate {
            return 1.0
        } else {
            let total = endDate.timeIntervalSince(startDate)
            let elapsed = now.timeIntervalSince(startDate)
            return elapsed / total
        }
    }
}

struct ProgressBar: View {
    let progress: Double  // значение от 0 до 1

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Незаполненная часть – серый фон
                Rectangle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                // Заполненная часть – тёмно-голубой цвет, заполняется сверху вниз
                Rectangle()
                    .fill(Color(UIColor.systemCyan))
                    .frame(width: geometry.size.width, height: geometry.size.height * CGFloat(progress))
                    .animation(.linear, value: progress)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .clipShape(RoundedRectangle(cornerRadius: 4)) // Скругляем все углы прогресс-бара
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
            .environmentObject(OrioksViewModel())
    }
}
