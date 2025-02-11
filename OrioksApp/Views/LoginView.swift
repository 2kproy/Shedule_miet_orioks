import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: OrioksViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showTokenLogin: Bool = false
    @State private var tokenInput: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Вход в ОРИОКС")
                    .font(.largeTitle)
                
                if showTokenLogin {
                    TextField("Введите токен", text: $tokenInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    Button(action: {
                        viewModel.tokenLogin(token: tokenInput)
                    }) {
                        Text("Войти по токену")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                } else {
                    TextField("Логин", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    SecureField("Пароль", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        viewModel.login(username: username, password: password)
                    }) {
                        Text("Войти")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                // Неприметная кнопка для переключения режима авторизации
                Button(action: {
                    withAnimation {
                        showTokenLogin.toggle()
                    }
                }) {
                    Text(showTokenLogin ? "Использовать логин и пароль" : "Авторизация по токену")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(OrioksViewModel())
    }
}
