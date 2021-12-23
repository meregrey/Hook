//
//  RootInteractor.swift
//  Hook
//
//  Created by Yeojin Yoon on 2021/12/23.
//

import AuthenticationServices
import RIBs
import RxSwift

protocol RootRouting: ViewableRouting {}

protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }
}

protocol RootListener: AnyObject {}

protocol RootInteractorDependency {
    var credentialRepository: CredentialRepositoryType { get }
    var loginStateStream: MutableLoginStateStreamType { get }
}

final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {
    
    private let dependency: RootInteractorDependency
    
    private var credentialRepository: CredentialRepositoryType { dependency.credentialRepository }
    private var loginStateStream: MutableLoginStateStreamType { dependency.loginStateStream }

    weak var router: RootRouting?
    weak var listener: RootListener?
    
    init(presenter: RootPresentable, dependency: RootInteractorDependency) {
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        validateCredential()
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    private func validateCredential() {
        switch credentialRepository.fetch() {
        case .success(let credential):
            guard let credential = credential else {
                loginStateStream.update(loginState: .loggedOut)
                return
            }
            authenticateCredential(credential)
        case .failure(let error):
            loginStateStream.update(loginState: .loggedOut)
            postNotification(with: error)
        }
    }
    
    private func authenticateCredential(_ credential: Credential) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: credential.identifier) { credentialState, _ in
            switch credentialState {
            case .authorized:
                self.loginStateStream.update(loginState: .loggedIn(credential: credential))
            default:
                self.deleteCredential()
                self.loginStateStream.update(loginState: .loggedOut)
            }
        }
    }
    
    private func deleteCredential() {
        switch credentialRepository.delete() {
        case .success(()):
            break
        case .failure(let error):
            postNotification(with: error)
        }
    }
    
    private func postNotification(with error: Error) {
        NotificationCenter.default.post(name: NotificationName.credentialErrorDidOccur,
                                        object: nil,
                                        userInfo: [NotificationUserInfoKey.error: error])
    }
}