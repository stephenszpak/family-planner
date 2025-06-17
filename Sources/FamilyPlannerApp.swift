import SwiftUI

@main
struct FamilyPlannerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var token: String? = UserDefaults.standard.string(forKey: "token")
    @State private var expiry: Date? = UserDefaults.standard.object(forKey: "token_expiry") as? Date

    var body: some View {
        if let token = token, let expiry = expiry, expiry > Date() {
            LoggedInView(token: token, logoutAction: logout)
        } else {
            AuthView(onLogin: { newToken in
                token = newToken
                expiry = Date().addingTimeInterval(60*60*24*180)
                UserDefaults.standard.set(token, forKey: "token")
                UserDefaults.standard.set(expiry, forKey: "token_expiry")
            })
        }
    }

    func logout() {
        token = nil
        expiry = nil
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "token_expiry")
    }
}

struct LoggedInView: View {
    let token: String
    let logoutAction: () -> Void

    var body: some View {
        VStack {
            Text("Logged in")
            Button("Logout", action: logoutAction)
        }
        .padding()
    }
}

struct AuthView: View {
    var onLogin: (String) -> Void

    @State private var isLogin = true
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""

    var body: some View {
        VStack {
            Picker("Mode", selection: $isLogin) {
                Text("Login").tag(true)
                Text("Register").tag(false)
            }
            .pickerStyle(.segmented)
            .padding()

            if !isLogin {
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .padding([.horizontal])
            }

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .padding([.horizontal])

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding([.horizontal])

            Button(isLogin ? "Login" : "Register") {
                if isLogin {
                    login()
                } else {
                    register()
                }
            }
            .padding()

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    func login() {
        guard let url = URL(string: "http://localhost:8000/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = LoginRequest(email: email, password: password)
        request.httpBody = try? JSONEncoder().encode(body)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard
                let data = data,
                let response = try? JSONDecoder().decode(TokenResponse.self, from: data)
            else {
                DispatchQueue.main.async { message = "Login failed" }
                return
            }
            DispatchQueue.main.async {
                onLogin(response.access_token)
                message = "Logged in"
            }
        }.resume()
    }

    func register() {
        guard let url = URL(string: "http://localhost:8000/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = RegisterRequest(username: username, email: email, password: password)
        request.httpBody = try? JSONEncoder().encode(body)
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                message = "Check your email for verification"
            }
        }.resume()
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
}

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
}
