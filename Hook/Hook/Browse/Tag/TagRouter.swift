//
//  TagRouter.swift
//  Hook
//
//  Created by Yeojin Yoon on 2022/01/07.
//

import RIBs

protocol TagInteractable: Interactable, TagBarListener, TagSettingsListener, EnterTagListener, EditTagsListener, SelectTagsListener, SearchTagsListener {
    var router: TagRouting? { get set }
    var listener: TagListener? { get set }
}

final class TagRouter: Router<TagInteractable>, TagRouting {
    
    private let baseViewController: BrowseViewControllable
    private let tagBar: TagBarBuildable
    private let tagSettings: TagSettingsBuildable
    private let enterTag: EnterTagBuildable
    private let editTags: EditTagsBuildable
    private let selectTags: SelectTagsBuildable
    private let searchTags: SearchTagsBuildable
    
    private var tagBarRouter: TagBarRouting?
    private var tagSettingsRouter: TagSettingsRouting?
    private var enterTagRouter: EnterTagRouting?
    private var editTagsRouter: EditTagsRouting?
    private var selectTagsRouter: SelectTagsRouting?
    private var searchTagsRouter: SearchTagsRouting?
    
    init(interactor: TagInteractable,
         baseViewController: BrowseViewControllable,
         tagBar: TagBarBuildable,
         tagSettings: TagSettingsBuildable,
         enterTag: EnterTagBuildable,
         editTags: EditTagsBuildable,
         selectTags: SelectTagsBuildable,
         searchTags: SearchTagsBuildable) {
        self.baseViewController = baseViewController
        self.tagBar = tagBar
        self.tagSettings = tagSettings
        self.enterTag = enterTag
        self.editTags = editTags
        self.selectTags = selectTags
        self.searchTags = searchTags
        super.init(interactor: interactor)
        interactor.router = self
    }
    
    func cleanupViews() {}
    
    // MARK: - TagBar
    
    func attachTagBar() {
        guard tagBarRouter == nil else { return }
        let router = tagBar.build(withListener: interactor)
        tagBarRouter = router
        attachChild(router)
        baseViewController.addChild(router.viewControllable)
    }
    
    // MARK: - TagSettings
    
    func attachTagSettings() {
        guard tagSettingsRouter == nil else { return }
        let router = tagSettings.build(withListener: interactor)
        tagSettingsRouter = router
        attachChild(router)
        baseViewController.push(router.viewControllable)
    }
    
    func detachTagSettings(includingView isIncludedView: Bool) {
        guard let router = tagSettingsRouter else { return }
        if isIncludedView { baseViewController.pop() }
        detachChild(router)
        tagSettingsRouter = nil
    }
    
    // MARK: - EnterTag
    
    func attachEnterTag(mode: EnterTagMode) {
        guard enterTagRouter == nil else { return }
        let router = enterTag.build(withListener: interactor, mode: mode)
        enterTagRouter = router
        attachChild(router)
        baseViewController.push(router.viewControllable)
    }
    
    func detachEnterTag(includingView isIncludedView: Bool) {
        guard let router = enterTagRouter else { return }
        if isIncludedView { baseViewController.pop() }
        detachChild(router)
        enterTagRouter = nil
    }
    
    // MARK: - EditTags
    
    func attachEditTags() {
        guard editTagsRouter == nil else { return }
        let router = editTags.build(withListener: interactor)
        editTagsRouter = router
        attachChild(router)
        baseViewController.push(router.viewControllable)
    }
    
    func detachEditTags(includingView isIncludedView: Bool) {
        guard let router = editTagsRouter else { return }
        if isIncludedView { baseViewController.pop() }
        detachChild(router)
        editTagsRouter = nil
    }
    
    // MARK: - SelectTags
    
    func attachSelectTags(existingSelectedTags: [Tag]) {
        guard selectTagsRouter == nil else { return }
        let router = selectTags.build(withListener: interactor, existingSelectedTags: existingSelectedTags)
        selectTagsRouter = router
        attachChild(router)
        baseViewController.presentOver(router.viewControllable)
    }
    
    func detachSelectTags() {
        guard let router = selectTagsRouter else { return }
        baseViewController.dismissOver()
        detachChild(router)
        selectTagsRouter = nil
    }
    
    // MARK: - SearchTags
    
    func attachSearchTags() {
        guard searchTagsRouter == nil else { return }
        guard let selectTagsRouter = selectTagsRouter else { return }
        let router = searchTags.build(withListener: interactor)
        searchTagsRouter = router
        attachChild(router)
        selectTagsRouter.viewControllable.present(router.viewControllable,
                                                  modalPresentationStyle: .currentContext,
                                                  animated: true)
    }
    
    func detachSearchTags() {
        guard let router = searchTagsRouter else { return }
        router.viewControllable.dismiss(animated: true)
        detachChild(router)
        searchTagsRouter = nil
    }
}
