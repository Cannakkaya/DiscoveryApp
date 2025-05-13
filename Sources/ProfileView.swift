import SwiftUI

struct ProfileView: View {
    @State private var username = "User"
    @State private var email = "user@example.com"
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var language = "English"
    @State private var currency = "TRY"
    @State private var isEditingProfile = false
    
    let languages = ["English", "Turkish", "German", "French", "Spanish"]
    let currencies = ["TRY", "USD", "EUR", "GBP"]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Personal Information")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(username)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(email)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isEditingProfile = true
                        }) {
                            Text("Edit")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                    
                    Picker("Language", selection: $language) {
                        ForEach(languages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                    
                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                }
                
                Section(header: Text("App")) {
                    NavigationLink(destination: Text("Privacy Policy")) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                    
                    NavigationLink(destination: Text("Terms of Service")) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    
                    NavigationLink(destination: Text("Help & Support")) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink(destination: Text("About")) {
                        Label("About", systemImage: "info.circle")
                    }
                }
                
                Section {
                    Button(action: {
                        // Sign out action
                    }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $isEditingProfile) {
                EditProfileView(username: $username, email: $email, isPresented: $isEditingProfile)
            }
        }
    }
}

struct EditProfileView: View {
    @Binding var username: String
    @Binding var email: String
    @Binding var isPresented: Bool
    
    @State private var tempUsername: String
    @State private var tempEmail: String
    
    init(username: Binding<String>, email: Binding<String>, isPresented: Binding<Bool>) {
        self._username = username
        self._email = email
        self._isPresented = isPresented
        self._tempUsername = State(initialValue: username.wrappedValue)
        self._tempEmail = State(initialValue: email.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Username", text: $tempUsername)
                    TextField("Email", text: $tempEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button("Change Password") {
                        // Show change password UI
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    username = tempUsername
                    email = tempEmail
                    isPresented = false
                }
                .fontWeight(.bold)
            )
        }
    }
}