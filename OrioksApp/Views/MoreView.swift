import SwiftUI

struct MoreView: View {
    @EnvironmentObject var viewModel: OrioksViewModel
    @State private var copyAlert: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Информация о студенте
                    if let student = viewModel.studentInfo {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Информация о студенте:")
                                .font(.headline)
                            Text("ФИО: \(student.full_name)")
                            Text("Группа: \(student.group)")
                            Text("Id: \(viewModel.groupId)")
                            Text("Курс: \(student.course)")
                            Text("Кафедра: \(student.department)")
                            Text("Зачётная книжка: \(student.record_book_id)")
                            Text("Семестр: \(student.semester)")
                            Text("Направление: \(student.study_direction)")
                            Text("Профиль: \(student.study_profile)")
                            Text("Учебный год: \(student.year)")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    } else {
                        Text("Информация о студенте не загружена")
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // Токен
                    if let token = viewModel.token {
                        Text("Токен:")
                            .font(.headline)
                        Text(token)
                            .font(.body)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = token
                                }) {
                                    Text("Скопировать")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                        
                        Button(action: {
                            UIPasteboard.general.string = token
                            copyAlert = true
                        }) {
                            Text("Скопировать токен")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .alert(isPresented: $copyAlert) {
                            Alert(title: Text("Скопировано"), message: Text("Токен скопирован в буфер обмена."), dismissButton: .default(Text("OK")))
                        }
                    } else {
                        Text("Токен не найден")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Ещё")
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
            .environmentObject(OrioksViewModel())
    }
}
