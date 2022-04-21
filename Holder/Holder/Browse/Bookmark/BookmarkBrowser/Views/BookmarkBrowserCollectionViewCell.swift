//
//  BookmarkBrowserCollectionViewCell.swift
//  Holder
//
//  Created by Yeojin Yoon on 2022/02/21.
//

import UIKit

final class BookmarkBrowserCollectionViewCell: UICollectionViewCell {
    
    @AutoLayout private var bookmarkListCollectionView = BookmarkListCollectionView()
    
    private var bookmarkListCollectionViewManager: BookmarkListCollectionViewManager?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookmarkListCollectionViewManager = nil
    }
    
    func configure(listener: BookmarkListCollectionViewListener?, tag: Tag?) {
        guard bookmarkListCollectionViewManager == nil else { return }
        bookmarkListCollectionViewManager = BookmarkListCollectionViewManager(collectionView: bookmarkListCollectionView,
                                                                              listener: listener,
                                                                              tag: tag)
        bookmarkListCollectionView.dataSource = bookmarkListCollectionViewManager
        bookmarkListCollectionView.prefetchDataSource = bookmarkListCollectionViewManager
        bookmarkListCollectionView.delegate = bookmarkListCollectionViewManager
        bookmarkListCollectionView.reloadData()
    }
    
    func bookmarkListCollectionViewContentOffset() -> CGPoint {
        return bookmarkListCollectionView.contentOffset
    }
    
    func setBookmarkListCollectionViewContentOffset(_ contentOffset: CGPoint) {
        bookmarkListCollectionView.layoutIfNeeded()
        bookmarkListCollectionView.contentOffset = contentOffset
    }
    
    private func configureViews() {
        contentView.addSubview(bookmarkListCollectionView)
        NSLayoutConstraint.activate([
            bookmarkListCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bookmarkListCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bookmarkListCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bookmarkListCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}