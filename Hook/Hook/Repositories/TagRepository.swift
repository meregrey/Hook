//
//  TagRepository.swift
//  Hook
//
//  Created by Yeojin Yoon on 2022/01/05.
//

import Foundation

protocol TagRepositoryType {
    var tagsStream: ReadOnlyStream<[Tag]> { get }
    func fetch()
    func add(tag: Tag)
    func update(tag: Tag, to newTag: Tag)
    func update(tags: [Tag])
}

final class TagRepository: TagRepositoryType {
    
    private let mutableTagsStream = MutableStream<[Tag]>(initialValue: [])
    private let persistentContainer: PersistentContainerType
    
    var tagsStream: ReadOnlyStream<[Tag]> { mutableTagsStream }
    
    init(persistentContainer: PersistentContainerType = PersistentContainer()) {
        self.persistentContainer = persistentContainer
        self.fetch()
    }
    
    func fetch() {
        persistentContainer.performBackgroundTask(with: NotificationName.Tag.didFailToFetchTags) { [weak self] context in
            let request = TagStorage.fetchRequest()
            guard let tags = try context.fetch(request).first?.extractTags() else {
                self?.setUpDefaultTag()
                return
            }
            self?.mutableTagsStream.update(with: tags)
        }
    }
    
    func add(tag: Tag) {
        if isExisting(tag) {
            postNotification(ofName: NotificationName.Tag.existingTag)
            return
        }
        persistentContainer.performBackgroundTask(with: NotificationName.Tag.didFailToAddTag) { [weak self] context in
            let request = TagStorage.fetchRequest()
            guard let tagStorage = try context.fetch(request).first else { return }
            tagStorage.tags = tagStorage.tags.appended(with: TagEntity(name: tag.name))
            try context.save()
            guard let newTagsStreamValue = self?.tagsStream.value.appended(with: tag) else { return }
            self?.mutableTagsStream.update(with: newTagsStreamValue)
            self?.postNotification(ofName: NotificationName.Tag.didSucceedToAddTag)
        }
    }
    
    func update(tag: Tag, to newTag: Tag) {
        if tag.name == newTag.name {
            return
        }
        if isExisting(newTag) {
            postNotification(ofName: NotificationName.Tag.existingTag)
            return
        }
        guard let tags = makeReplacedTags(tag, with: newTag) else { return }
        persistentContainer.performBackgroundTask(with: NotificationName.Tag.didFailToUpdateTag) { [weak self] context in
            let request = TagStorage.fetchRequest()
            guard let tagStorage = try context.fetch(request).first else { return }
            tagStorage.tags = tags.map { $0.converted() }
            try context.save()
            self?.mutableTagsStream.update(with: tags)
        }
    }
    
    func update(tags: [Tag]) {
        persistentContainer.performBackgroundTask(with: NotificationName.Tag.didFailToUpdateTags) { [weak self] context in
            let request = TagStorage.fetchRequest()
            guard let tagStorage = try context.fetch(request).first else { return }
            tagStorage.tags = tags.map { $0.converted() }
            try context.save()
            self?.mutableTagsStream.update(with: tags)
        }
    }
    
    private func setUpDefaultTag() {
        persistentContainer.performBackgroundTask(with: NotificationName.Tag.didFailToSetUpDefaultTag) { [weak self] context in
            let tagStorage = TagStorage(context: context)
            tagStorage.tags = [TagEntity(name: TagName.all)]
            try context.save()
            self?.mutableTagsStream.update(with: [Tag(name: TagName.all)])
        }
    }
    
    private func isExisting(_ tag: Tag) -> Bool {
        return tagsStream.value.contains(tag)
    }
    
    private func postNotification(ofName name: NSNotification.Name, object: Any? = nil) {
        NotificationCenter.default.post(name: name, object: object)
    }
    
    private func makeReplacedTags(_ tag: Tag, with newTag: Tag) -> [Tag]? {
        var tags = tagsStream.value
        guard let index = tags.firstIndex(of: tag) else { return nil }
        tags[index] = newTag
        return tags
    }
}
