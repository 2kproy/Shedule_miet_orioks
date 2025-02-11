import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: OrioksViewModel
    @State private var showingErrorAlert = false
    
    var body: some View {
        TabView {
            ScheduleView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Расписание")
                }
            // Заглушка для "Баллов"
            Text("Баллы")
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Баллы")
                }
            MoreView()
                .tabItem {
                    Image(systemName: "ellipsis.circle")
                    Text("Ещё")
                }
        }
        // Отслеживаем изменение ошибки в viewModel
        .onChange(of: viewModel.errorMessage) { newValue, _ in
            if newValue != nil {
                showingErrorAlert = true
            }
        }
        // Настройка всплывающего сообщения (Alert)
        .alert(isPresented: $showingErrorAlert) {
            Alert(
                title: Text("Ошибка"),
                message: Text(viewModel.errorMessage ?? "Неизвестная ошибка"),
                dismissButton: .default(Text("OK"), action: {
                    // Сбрасываем ошибку после закрытия alert
                    viewModel.errorMessage = nil
                })
            )
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(OrioksViewModel())
    }
}
