//
//  PTCollectionView.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/25.
//
import UIKit

protocol PTCollectionViewDelegate: UICollectionViewDelegate {
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}
class PTCollectionView: UIView {

    weak var ptCollectionDelegate: PTCollectionViewDelegate?
    private let collectionView: UICollectionView

    var items: [Any] = [] {
        didSet { collectionView.reloadData() }
    }

    private let reuseId: String
    private let cellType: UICollectionViewCell.Type

    init(cellType: UICollectionViewCell.Type,
         reuseId: String = "PTCell",
         itemSize: CGSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 60))
    {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = itemSize
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.cellType = cellType
        self.reuseId = reuseId

        super.init(frame: .zero)

        setupConfig()
        setupUI()
    }

    private func setupConfig() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self

        collectionView.register(cellType, forCellWithReuseIdentifier: reuseId)
        collectionView.delegate = ptCollectionDelegate
    }

    private func setupUI() {
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PTCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath)
        ptCollectionDelegate?.configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
}
