//
//  CredentialRepository.swift
//  Hook
//
//  Created by Yeojin Yoon on 2021/12/21.
//

import AuthenticationServices
import Foundation

protocol CredentialRepositoryType {
    var loginStateStream: ReadOnlyStream<LoginState> { get }
    func verify()
    func save(credential: Credential) -> Result<Void, Error>
    func delete()
}

final class CredentialRepository: CredentialRepositoryType {
    
    private let mutableLoginStateStream = MutableStream<LoginState>(initialValue: .loggedOut)
    private let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    private let keychainManager: KeychainManageable
    
    var loginStateStream: ReadOnlyStream<LoginState> { mutableLoginStateStream }
    
    init(keychainManager: KeychainManageable = KeychainManager()) {
        self.keychainManager = keychainManager
    }
    
    func verify() {
        switch fetch() {
        case .success(let credential):
            guard let credential = credential else {
                mutableLoginStateStream.update(with: .loggedOut)
                return
            }
            authenticate(credential: credential)
        case .failure(_):
            deleteKeychainItem()
            mutableLoginStateStream.update(with: .loggedOut)
        }
    }
    
    func save(credential: Credential) -> Result<Void, Error> {
        do {
            let attributes = [kSecAttrService: bundleIdentifier, kSecAttrAccount: credential.name]
            try keychainManager.addItem(credential.identifier,
                                        itemClass: kSecClassGenericPassword,
                                        itemAttributes: attributes)
            mutableLoginStateStream.update(with: .loggedIn(credential: credential))
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func delete() {
        deleteKeychainItem()
        mutableLoginStateStream.update(with: .loggedOut)
    }
    
    private func fetch() -> Result<Credential?, Error> {
        var item: KeychainItem<String>?
        do {
            item = try keychainManager.searchItem(ofClass: kSecClassGenericPassword, itemAttributes: [kSecAttrService: bundleIdentifier])
        } catch {
            return .failure(error)
        }
        guard let item = item else { return .success(nil) }
        guard let name = item.account else { return .success(nil) }
        let credential = Credential(identifier: item.value, name: name)
        return .success(credential)
    }
    
    private func authenticate(credential: Credential) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: credential.identifier) { credentialState, _ in
            switch credentialState {
            case .authorized:
                self.mutableLoginStateStream.update(with: .loggedIn(credential: credential))
            default:
                self.deleteKeychainItem()
                self.mutableLoginStateStream.update(with: .loggedOut)
            }
        }
    }
    
    private func deleteKeychainItem() {
        try? keychainManager.deleteItem(ofClass: kSecClassGenericPassword, itemAttributes: [kSecAttrService: bundleIdentifier])
    }
}