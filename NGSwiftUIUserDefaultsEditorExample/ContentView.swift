//
//  ContentView.swift
//  NGSwiftUIUserDefaultsEditorExample
//
//  Created by Noah Gilmore on 5/4/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import SwiftUI
import Combine

@propertyWrapper
struct SimpleUserDefault<T> {
    let userDefaults: UserDefaults
    let key: String
    let defaultValue: T

    init(
        userDefaults: UserDefaults = UserDefaults.standard,
        key: String,
        defaultValue: T
    ) {
        self.userDefaults = userDefaults
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            guard let data = userDefaults.object(forKey: key) as? T else { return self.defaultValue }
            return data
        }

        set {
            userDefaults.set(newValue, forKey: key)
        }
    }
}

class UserDefaultsConfig: ObservableObject {
    static let shared = UserDefaultsConfig()

    let objectWillChange = PassthroughSubject<Void, Never>()

    @SimpleUserDefault(key: "com.getfluencyio.is-test-mode-enabled", defaultValue: false)
    var testModeEnabled: Bool {
        willSet {
            objectWillChange.send()
        }
    }

    @SimpleUserDefault(key: "com.getfluencyio.is-new-ui-enabled", defaultValue: false)
    var newUIEnabled: Bool {
        willSet {
            objectWillChange.send()
        }
    }
}

extension Binding {
    init<RootType>(keyPath: ReferenceWritableKeyPath<RootType, Value>, object: RootType) {
        self.init(
            get: { object[keyPath: keyPath] },
            set: { object[keyPath: keyPath] = $0}
        )
    }
}

struct UserDefaultsConfigToggleItemView: View {
    @ObservedObject var defaultsConfig = UserDefaultsConfig.shared
    let path: ReferenceWritableKeyPath<UserDefaultsConfig, Bool>
    let name: String

    var body: some View {
        HStack {
            Toggle(isOn: Binding(keyPath: self.path, object: self.defaultsConfig)) {
                Text(name)
            }
            Spacer()
        }
    }
}

struct UserDefaultsView: View {
    var body: some View {
        List {
            UserDefaultsConfigToggleItemView(path: \.testModeEnabled, name: "Test Mode")
            UserDefaultsConfigToggleItemView(path: \.newUIEnabled, name: "Hide Test Mode UI")
        }.navigationBarTitle("UserDefaults Editor", displayMode: .inline)
    }
}

struct IndicatorView: View {
    let enabled: Bool
    let text: String

    var body: some View {
        VStack(spacing: 4) {
            Text(self.text + ":")
            Text(self.enabled ? "ON" : "OFF")
                .font(.callout)
                .bold()
                .padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 8)
                .background(self.enabled ? Color.green : Color.red)
                .cornerRadius(8)
        }
    }
}

struct ContentView: View {
    @ObservedObject var config = UserDefaultsConfig.shared

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    IndicatorView(enabled: config.testModeEnabled, text: "Debug mode")
                    Spacer()
                    IndicatorView(enabled: config.newUIEnabled, text: "New UI")
                    Spacer()
                }
                Spacer()
                NavigationLink(destination: UserDefaultsView(), label: { Text("Edit") })
            }.padding(50)
        }
        .navigationBarTitle("Home")
    }
}
