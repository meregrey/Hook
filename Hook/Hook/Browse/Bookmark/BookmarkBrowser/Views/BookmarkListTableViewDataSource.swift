//
//  BookmarkListTableViewDataSource.swift
//  Hook
//
//  Created by Yeojin Yoon on 2022/02/22.
//

import CoreData
import UIKit

final class BookmarkListTableViewDataSource: NSObject, UITableViewDataSource {

    private let fetchedResultsControllerDelegate: FetchedResultsControllerDelegate

    private var isForAll = false
    private var fetchedResultsControllerForAll: NSFetchedResultsController<BookmarkEntity>?
    private var fetchedResultsControllerForTag: NSFetchedResultsController<BookmarkTagEntity>?

    init(tableView: UITableView, tag: Tag, context: NSManagedObjectContext) {
        self.fetchedResultsControllerDelegate = FetchedResultsControllerDelegate(tableView: tableView)
        super.init()
        if tag.name == TagName.all {
            self.isForAll = true
            self.fetchedResultsControllerForAll = fetchedResultsControllerForAll(context: context)
            self.fetchedResultsControllerForAll?.delegate = fetchedResultsControllerDelegate
            try? self.fetchedResultsControllerForAll?.performFetch()
        } else {
            self.fetchedResultsControllerForTag = fetchedResultsControllerForTag(tag: tag, context: context)
            self.fetchedResultsControllerForTag?.delegate = fetchedResultsControllerDelegate
            try? self.fetchedResultsControllerForTag?.performFetch()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return 1 }
        if isForAll {
            guard let fetchedObjects = fetchedResultsControllerForAll?.fetchedObjects else { return 0 }
            return fetchedObjects.count
        } else {
            guard let fetchedObjects = fetchedResultsControllerForTag?.fetchedObjects else { return 0 }
            return fetchedObjects.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 { return transparentCell() }
        let cell: BookmarkListTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if isForAll {
            guard let bookmarkEntity = fetchedResultsControllerForAll?.object(at: indexPath) else { return cell }
            cell.configure(with: bookmarkEntity)
            return cell
        } else {
            guard let bookmarkEntity = fetchedResultsControllerForTag?.object(at: indexPath).bookmark else { return cell }
            cell.configure(with: bookmarkEntity)
            return cell
        }
    }

    private func fetchedResultsControllerForAll(context: NSManagedObjectContext) -> NSFetchedResultsController<BookmarkEntity> {
        let request = BookmarkEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(BookmarkEntity.creationDate), ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }

    private func fetchedResultsControllerForTag(tag: Tag, context: NSManagedObjectContext) -> NSFetchedResultsController<BookmarkTagEntity> {
        let request = BookmarkTagEntity.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(BookmarkTagEntity.name), tag.name)
        let sortDescriptor = NSSortDescriptor(key: #keyPath(BookmarkTagEntity.bookmark.creationDate), ascending: false)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }

    private func transparentCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
}

//final class BookmarkListTableViewDataSource: NSObject, UITableViewDataSource {
//
//    private let bookmarks: [Bookmark] = [Bookmark(url: URL(string: "https://developer.apple.com")!, isFavorite: false, tags: nil, note: nil, title: "Title", host: "host.com"),
//                                         Bookmark(url: URL(string: "https://developer.apple.com")!, isFavorite: false, tags: nil, note: nil, title: "Title", host: "host.com"),
//                                         Bookmark(url: URL(string: "https://developer.apple.com")!, isFavorite: false, tags: nil, note: nil, title: "Title", host: "host.com"),
//                                         Bookmark(url: URL(string: "https://developer.apple.com")!, isFavorite: false, tags: nil, note: nil, title: "Title", host: "host.com"),
//                                         Bookmark(url: URL(string: "https://developer.apple.com")!, isFavorite: false, tags: nil, note: nil, title: "Title", host: "host.com"),
//                                         Bookmark(url: URL(string: "https://developer.apple.com")!, isFavorite: false, tags: nil, note: nil, title: "Title", host: "host.com"),
//                                         Bookmark(url: URL(string: "https://developer.apple.com")!, isFavorite: false, tags: nil, note: nil, title: "Title", host: "host.com"),
//                                         Bookmark(url: URL(string: "https://developer.apple.com")!, isFavorite: false, tags: nil, note: nil, title: "Title", host: "host.com"),
//                                         Bookmark(url: URL(string: "https://developer.apple.com")!, isFavorite: false, tags: nil, note: nil, title: "Title", host: "host.com"),
//                                         Bookmark(url: URL(string: "https://developer.apple.com")!, isFavorite: false, tags: nil, note: nil, title: "Title", host: "host.com")]
//
//    init(tableView: UITableView, tag: Tag, context: NSManagedObjectContext) {
//
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 1 { return 1 }
//        return bookmarks.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 1 { return transparentCell() }
//        let cell: BookmarkListTableViewCell = tableView.dequeueReusableCell(for: indexPath)
//        cell.configure(with: bookmarks[indexPath.row])
//        return cell
//    }
//
//    private func transparentCell() -> UITableViewCell {
//        let cell = UITableViewCell()
//        cell.selectionStyle = .none
//        cell.backgroundColor = .clear
//        return cell
//    }
//}