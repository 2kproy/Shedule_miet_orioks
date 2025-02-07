import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var viewModel: OrioksViewModel
    
    var body: some View {
        NavigationView {
            Group {
//                if let schedule = viewModel.schedule {
//                    // Для демонстрации выбираем расписание недели с ключом "0"
//                    if let weekSchedule = schedule.weeks["1"] {
//                        List {
//                            ForEach(weekSchedule.keys.sorted(), id: \.self) { day in
//                                if let pairs = weekSchedule[day] {
//                                    Section(header: Text(day.capitalized)) {
//                                        ForEach(pairs.keys.sorted(), id: \.self) { pairNumber in
//                                            if let classInfo = pairs[pairNumber] {
//                                                HStack {
//                                                    VStack(alignment: .leading, spacing: 4) {
//                                                        Text("Пара \(pairNumber)")
//                                                            .font(.subheadline)
//                                                            .foregroundColor(.gray)
//                                                        Text(classInfo.name)
//                                                            .font(.headline)
//                                                        Text("Кабинет: \(classInfo.classroom)")
//                                                            .font(.subheadline)
//                                                            .foregroundColor(.secondary)
//                                                        Text("Преподаватель: \(classInfo.teacher)")
//                                                            .font(.subheadline)
//                                                            .foregroundColor(.secondary)
//                                                    }
//                                                    Spacer()
//                                                    VStack {
//                                                        Text("00:00")
//                                                            .font(.caption)
//                                                        Rectangle()
//                                                            .fill(Color.green)
//                                                            .frame(width: 4, height: 50)
//                                                        Text("00:00")
//                                                            .font(.caption)
//                                                    }
//                                                }
//                                                .padding(.vertical, 8)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
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
