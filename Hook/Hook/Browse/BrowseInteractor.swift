//
//  BrowseInteractor.swift
//  Hook
//
//  Created by Yeojin Yoon on 2022/01/02.
//

import RIBs

protocol BrowseRouting: ViewableRouting {
    func attachTag()
}

protocol BrowsePresentable: Presentable {
    var listener: BrowsePresentableListener? { get set }
}

protocol BrowseListener: AnyObject {}

final class BrowseInteractor: PresentableInteractor<BrowsePresentable>, BrowseInteractable, BrowsePresentableListener {

    weak var router: BrowseRouting?
    weak var listener: BrowseListener?
    
    override init(presenter: BrowsePresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        router?.attachTag()
    }

    override func willResignActive() {
        super.willResignActive()
    }
}
