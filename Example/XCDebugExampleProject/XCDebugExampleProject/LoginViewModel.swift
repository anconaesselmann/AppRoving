//  Created by Axel Ancona Esselmann on 11/12/23.
//

import Foundation
import Combine
import SwiftUI


struct LoginView: View {

    @StateObject
    var vm = LoginViewModel()

    var body: some View {
        ZStack {
            VStack {
                TextField("Email", text: $vm.email)
                SecureField("Password", text: $vm.password)
                #if !os(tvOS)
                DatePicker("Birthday", selection: $vm.birthday)
                #endif
                TextField("A Number", text: $vm.aNumber)
                TextField("A Double", text: $vm.aDouble)
                TextField("Screen", text: $vm.screen)
                TextField("Int enum", text: $vm.intEnum)
                TextField("Double enum", text: $vm.doubleEnum)
                Button("Log in") {
                    vm.logIn()
                }.register(.loginButton)
                Button("Simulate") {
                    CustomEventManager.shared.eventFired(.init(id: EventId.loginButton.uuid, sender: UUID()))
                }
            }
            #if os(tvOS)
            .textFieldStyle(.automatic)
            #else
            .textFieldStyle(.roundedBorder)
            #endif
            if vm.loading {
                ProgressView()
            }
        }
    }
}

@MainActor
class LoginViewModel: ObservableObject {

    private var bag = Set<AnyCancellable>()

    var navManager = NavManager.shared

    let service = Service()

    @MainActor
    var loading = false

    var email = ""
    var password = ""
    var birthday = Date()
    var aNumber = ""
    var aDouble = ""

    var screen = ""
    var intEnum = ""
    var doubleEnum = ""

    init() {
#if DEBUG
        XCDebug.onChange {
            self.update()
        }.store(in: &bag)
#endif
    }

    func update() {
        email = XCDebug.get(\LoginDebug.userName) ?? ""
        password = XCDebug.get(\LoginDebug.password) ?? ""
        birthday = XCDebug.get(\LoginDebug.birthday) ?? Date()
        if let number = XCDebug.get(\LoginDebug.aNumber) {
            aNumber = "\(number)"
        } else {
            aNumber = ""
        }
        if let number = XCDebug.get(\LoginDebug.aDouble) {
            aDouble = "\(number)"
        } else {
            aDouble = ""
        }
        screen = XCDebug.get(\LoginDebug.anEnum)?.stringValue ?? ""
        intEnum = XCDebug.get(\LoginDebug.anIntEnum)?.stringValue ?? ""
        doubleEnum = XCDebug.get(\LoginDebug.aDoubleEnum)?.stringValue ?? ""
        self.objectWillChange.send()
    }

    @MainActor
    func setLoading(_ isLoading: Bool) {
        self.loading = isLoading
        self.objectWillChange.send()
    }

    func logIn() {
        Task {
            setLoading(true)
            try await service.logIn(email: email, password: password)
            setLoading(false)
            navManager.path.append(Screen.loggedIn)
        }
    }
}
