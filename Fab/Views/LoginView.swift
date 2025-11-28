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
                .animation(.easeInOut(duration: 0.3), value: isLoginMode)
            
            VStack(spacing: 16) {
                if !isLoginMode {
                    TextField("Nom d'utilisateur", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .transition(.move(edge: .top).combined(with: .opacity))
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
                            .transition(.opacity.combined(with: .scale))
                    } else {
                        Text(isLoginMode ? "Se connecter" : "S'inscrire")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty || (!isLoginMode && userName.isEmpty))
                .animation(.easeInOut(duration: 0.2), value: isLoading)
                .animation(.easeInOut(duration: 0.2), value: isLoginMode)
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isLoginMode.toggle()
                        errorMessage = ""
                    }
                }) {
                    Text(isLoginMode ? "Pas de compte ? S'inscrire" : "Déjà un compte ? Se connecter")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, 32)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoginMode)
            
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

