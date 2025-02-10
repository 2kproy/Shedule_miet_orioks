import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var viewModel: OrioksViewModel

    var body: some View {
        NavigationView {
            Group {
                if let ts = viewModel.transformedSchedule,
                   let weekSchedule = ts.week_type[String(viewModel.currentWeekType)] {  // используем расписание для типа недели "0"
                    ScrollView {
                        VStack(spacing: 16) {
                            ///Верхняя часть
                            
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
                                        Text("Тип недели: \(viewModel.currentWeekType)")
                                            .font(.subheadline)
                                    )
                            }
                            .padding(.horizontal)
                            
                           
                            .padding(.vertical, 4)
                            
                            // Основной список расписания, сгруппированный по дням
                            // Здесь мы используем фиксированный порядок дней
                            ForEach(["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"], id: \.self) { day in
                                if let lessons = weekSchedule[day] {
                                    // Оборачиваем секцию дня в плашку с закругленными краями
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(day.uppercased())
                                            .foregroundColor(.gray)
                                            .font(.headline)
                                            .bold()
                                            .padding(.leading, 8)
                                        VStack(spacing: 4) {
                                            ForEach(lessons.keys.sorted(), id: \.self) { lessonNumber in
                                                if let lesson = lessons[lessonNumber] {
                                                    ClassRowView(lessonNumber: lessonNumber, lesson: lesson)
                                                }
                                                Divider()
                                                        .background(Color.gray)
                                                        .padding(.horizontal, 16)
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
}

struct ClassRowView: View {
    @EnvironmentObject var viewModel: OrioksViewModel
    let lessonNumber: String
    let lesson: LessonInfo
    
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
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let start = formatter.date(from: lesson.time_start),
              let end = formatter.date(from: lesson.time_end) else {
            return 0.0
        }
        let now = Date()
        if now < start {
            return 0.0
        } else if now > end {
            return 1.0
        } else {
            let total = end.timeIntervalSince(start)
            let elapsed = now.timeIntervalSince(start)
            return elapsed / total
        }
    }
}

struct ProgressBar: View {
    let progress: Double  // от 0 до 1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                Rectangle()
                    .fill(Color.green)
                    .frame(width: geometry.size.width, height: geometry.size.height * CGFloat(progress))
                    .animation(.linear, value: progress)
            }
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
            .environmentObject(OrioksViewModel())
    }
}
/*import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var viewModel: OrioksViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if let schedule = viewModel.schedule {
                    // неделя (0...3)
                    if let weekSchedule = schedule.weeks["1"] {
                        List {
                            ForEach(weekSchedule.keys.sorted(), id: \.self) { day in
                                if let pairs = weekSchedule[day] {
                                    Section(header: Text(day.capitalized)) {
                                        ForEach(pairs.keys.sorted(), id: \.self) { pairNumber in
                                            if let classInfo = pairs[pairNumber] {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text("Пара \(pairNumber)")
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                        Text(classInfo.name)
                                                            .font(.headline)
                                                        Text("Кабинет: \(classInfo.classroom)")
                                                            .font(.subheadline)
                                                            .foregroundColor(.secondary)
                                                        Text("Преподаватель: \(classInfo.teacher)")
                                                            .font(.subheadline)
                                                            .foregroundColor(.secondary)
                                                    }
                                                    Spacer()
                                                    // Здесь вместо заглушки выводим реальные данные из timetable
                                                    if let times = viewModel.timetable?[pairNumber], times.count == 2 {
                                                        VStack {
                                                            Text(times[0])
                                                                .font(.caption)
                                                            Rectangle()
                                                                .fill(Color.green)
                                                                .frame(width: 4, height: 50)
                                                            Text(times[1])
                                                                .font(.caption)
                                                        }
                                                    } else {
                                                        // Если для данной пары время не найдено – показываем заглушку
                                                        VStack {
                                                            Text("--")
                                                                .font(.caption)
                                                            Rectangle()
                                                                .fill(Color.green)
                                                                .frame(width: 4, height: 50)
                                                            Text("--")
                                                                .font(.caption)
                                                        }
                                                    }
                                                }
                                                .padding(.vertical, 8)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        Text("ОРИОКС еще не выложили расписание для сторонних разработчиков 🫠")
                    }
                } else {
                    VStack {
                        Spacer()
                        ProgressView("Загрузка расписания...")
                        Spacer()
                    }
                }
            }
            .navigationTitle("Расписание")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.fetchSchedule()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
            .environmentObject(OrioksViewModel())
    }
}
/*
import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var viewModel: OrioksViewModel

    // Вычисляемое свойство для группировки расписания по дню (если newSchedule существует)
    private var sortedGroups: [(key: Int, value: [ScheduleItem])] {
        guard let schedule = viewModel.newSchedule else { return [] }
        let grouped = Dictionary(grouping: schedule.data, by: { $0.day })
        return grouped.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        NavigationView {
            if let newSchedule = viewModel.newSchedule {
                List {
                    Section(header: Text(newSchedule.semestr)) {
                        ForEach(sortedGroups, id: \.key) { group in
                            Section(header: Text(dayName(from: group.key))) {
                                ForEach(group.value.sorted { $0.time.code < $1.time.code }) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Пара \(item.time.code)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Text(item.classInfo.name)
                                                .font(.headline)
                                            Text("Кабинет: \(item.room.name)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Text("Преподаватель: \(item.classInfo.teacherFull)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        VStack {
                                            Text(formattedTime(from: item.time.timeFrom, to: item.time.timeTo))
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationTitle("Расписание")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewModel.fetchNewSchedule() }) {
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
    
    // Преобразует числовой день (1...6) в название на русском языке
    private func dayName(from day: Int) -> String {
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
    
    // Форматирует время занятия: "HH:mm - HH:mm"
    private func formattedTime(from timeFrom: Date, to timeTo: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: timeFrom)) - \(formatter.string(from: timeTo))"
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
            .environmentObject(OrioksViewModel())
    }
}*/*/
