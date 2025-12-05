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
    
    // 控制點擊
    func didSelectItem(at indexPath: IndexPath)
    
    // 控制變形
    func flowLayout(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}

class PTCollectionView: UIView {

    weak var ptCollectionDelegate: PTCollectionViewDelegate?
    private let collectionView: UICollectionView
    

    var items: [Any] = [] {
        didSet { collectionView.reloadData() }
    }
    var collectionViewLayout: UICollectionViewLayout {
        return collectionView.collectionViewLayout
    }

    private let reuseId: String
    private let cellType: UICollectionViewCell.Type

    init(cellType: UICollectionViewCell.Type)
    {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12

        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.cellType = cellType
        let reuseId = String(describing: cellType)
        self.reuseId = reuseId

        super.init(frame: .zero)

        setupConfig()
        setupUI()
    }

    private func setupConfig() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(cellType, forCellWithReuseIdentifier: reuseId)
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
    
    func reloadItems(at indexPaths: [IndexPath]){
        collectionView.reloadItems(at: indexPaths)
    }
    
    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell?{
        return collectionView.cellForItem(at: indexPath)
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

extension PTCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return (ptCollectionDelegate?.flowLayout(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath))!
    }
}

extension PTCollectionView: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ptCollectionDelegate?.didSelectItem(at: indexPath)
    }
}

extension PTCollectionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ptCollectionDelegate?.scrollViewDidScroll(scrollView)
    }

}
