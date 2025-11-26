import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var userName: String = ""
    @State private var isLoginMode: Bool = true
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Fab")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.blue)
            
            Text(isLoginMode ? "Connexion" : "Créer un compte")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                if !isLoginMode {
                    TextField("Nom d'utilisateur", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                
                SecureField("Mot de passe", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(isLoginMode ? .password : .newPassword)
                
                Button(action: {
                    Task {
                        await handleAuth()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(isLoginMode ? "Se connecter" : "S'inscrire")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty || (!isLoginMode && userName.isEmpty))
                
                Button(action: {
                    isLoginMode.toggle()
                    errorMessage = ""
                }) {
                    Text(isLoginMode ? "Pas de compte ? S'inscrire" : "Déjà un compte ? Se connecter")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .alert("Erreur", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleAuth() async {
        isLoading = true
        errorMessage = ""
        
        do {
            if isLoginMode {
                try await authService.login(email: email, password: password)
            } else {
                try await authService.register(email: email, password: password, userName: userName)
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
}

