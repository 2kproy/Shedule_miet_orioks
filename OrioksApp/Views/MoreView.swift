import SwiftUI

struct MoreView: View {
    @EnvironmentObject var viewModel: OrioksViewModel
    @State private var signOutAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Секция информации о студенте (оставляем без изменений)
                    if let student = viewModel.studentInfo {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Информация о студенте:")
                                .font(.headline)
                            Text("ФИО: \(student.full_name)")
                            Text("Группа: \(student.group)")
                            //Text("Id: \(viewModel.groupId)")
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
                    
                    // Секция кнопок в стиле настроек (как в Telegram)
                    VStack(spacing: 0) {
                        NavigationLink {
                            AboutView()
                        } label: {
                            HStack {
                                Label("Об приложении", systemImage: "info.circle")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                        Divider()
                        Button {
                            // Пока неактивная кнопка для поддержки автора.
                        } label: {
                            HStack {
                                Label("Поддержать автора", systemImage: "heart")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                        .disabled(true)
                        Divider()
                        NavigationLink {
                            DeveloperInfoView()
                        } label: {
                            HStack {
                                Label("Для разработчиков", systemImage: "hammer")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                        Divider()
                        Button(role: .destructive) {
                            signOutAlert = true
                        } label: {
                            HStack {
                                Label("Выйти из аккаунта", systemImage: "arrow.backward.circle")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Ещё")
            .alert("Выйти из аккаунта?", isPresented: $signOutAlert) {
                Button("Выйти", role: .destructive) {
                    signOut()
                }
                Button("Отмена", role: .cancel) { }
            }
        }
    }
    
    private func signOut() {
        guard let token = viewModel.token else {
            viewModel.isAuthenticated = false
            return
        }
        APIManager.revokeToken(token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Если сервер вернул 200, аннулируем токен локально
                    viewModel.token = nil
                    KeychainHelper.standard.delete(service: "com.orioks.app", account: "userToken")
                    viewModel.isAuthenticated = false
                case .failure(let error):
                    // Здесь можно показать ошибку, если аннулирование не удалось
                    print("Ошибка аннулирования токена: \(error.localizedDescription)")
                    // Если необходимо, можно всё равно выполнить выход или сообщить пользователю
                }
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Powered by 2kproy")
                .font(.largeTitle)
                .bold()
            Text("Здесь будет информация о программе и ссылки на соцсети.")
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .padding()
        .navigationTitle("О программе")
    }
}

struct DeveloperInfoView: View {
    @EnvironmentObject var viewModel: OrioksViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let token = viewModel.token {
                Text("Токен аутентификации ORIOKS:")
                    .font(.headline)
                Text(token)
                    .font(.body)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = token
                        } label: {
                            Label("Скопировать", systemImage: "doc.on.doc")
                        }
                    }
            } else {
                Text("Токен не найден")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Для разработчиков")
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
            .environmentObject(OrioksViewModel())
    }
}
/*import SwiftUI

struct MoreView: View {
    @EnvironmentObject var viewModel: OrioksViewModel
    @State private var copyAlert: Bool = false
    
    var body: some View {
        NavigationStack {
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
            List {
                Section {
                    NavigationLink {
                        //AboutView()
                    } label: {
                        Label("О программе", systemImage: "info.circle")
                    }
                    
                    Button {
                        // Пока неактивная кнопка – можно добавить действие в будущем
                    } label: {
                        Label("Поддержать автора", systemImage: "heart")
                    }
                    .disabled(true)
                    
                    NavigationLink {
                        //DeveloperInfoView()
                    } label: {
                        Label("Для разработчиков", systemImage: "hammer")
                    }
                }
                .navigationTitle("Ещё")
            }
        }
    }
}
struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
            .environmentObject(OrioksViewModel())
    }
}*/

