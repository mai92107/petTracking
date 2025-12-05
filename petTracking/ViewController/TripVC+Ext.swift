//
//  TrackingVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit
import CoreLocation

final class TripVC: BaseVC {

    private var trips: [TripModel] = [] {
        didSet {
            tripCollection.items = trips
        }
    }
    private var tripDetails: [String:TripDetail] = [:]
    private var currentPage: Int64 = 0
    private var totalPages: Int64 = 1
    private var sizePerPage: Int64 = 10
    private var lastLoadTime: Date = .distantPast
    private let loadInterval: TimeInterval = 1.0   // 1 秒間隔
    private var expandedIndexes: Set<IndexPath> = []

    
    // MARK: - UI Components
    private let titleLabel = PTLabel(text: "Trip History", with: .title)
    
    private let tripCollection = PTCollectionView(cellType: TripViewCell.self)

    // MARK: - View Entrence
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConfig()
        setupUI()
        
        // 取得資料
        getTripHistory()
    }

    // MARK: - Config
    private func setupConfig(){
        tripCollection.ptCollectionDelegate = self
    }
    
    // MARK: - Layout
    private func setupUI() {
        view.backgroundColor = .ptQuaternary
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tripCollection.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(tripCollection)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            tripCollection.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tripCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tripCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tripCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
       ])
    }
}

extension TripVC: PTCollectionViewDelegate{
    func didSelectItem(at indexPath: IndexPath) {

        if expandedIndexes.contains(indexPath){
            expandedIndexes.remove(indexPath)
        }else{
            expandedIndexes.insert(indexPath)
        }
        tripCollection.reloadItems(at: [indexPath])

        UIView.animate(withDuration: 0.25) {
            self.tripCollection.collectionViewLayout.invalidateLayout()
            self.tripCollection.layoutIfNeeded()
        }
    }
    
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        let cell = cell as! TripViewCell
        let model = trips[indexPath.item]
        
        let isExpanded: Bool = expandedIndexes.contains(indexPath)
        cell.setIsExpanded(isExpanded, detail: nil)
        cell.configure(time: model.time, distance: model.distance, duration: model.duration)
        
        // 處理展開狀態
        if isExpanded {
            let uuid = model.uuid
            if let detail = tripDetails[uuid] {
                // 已有快取,直接顯示
                cell.setIsExpanded(isExpanded, detail: detail)
            } else {
                // 無快取,先顯示 loading
                cell.setIsExpanded(isExpanded, detail: nil)
                
                // ✅ 只在展開且無快取時才取得 detail
                getTripDetail(uuid: uuid) { [weak self] detail in
                    guard let self = self else { return }
                    
                    // 確認 cell 仍然是展開狀態且在畫面上
                    if self.expandedIndexes.contains(indexPath),
                       let currentCell = self.tripCollection.cellForItem(at: indexPath) as? TripViewCell {
                        currentCell.updateExpandedDetail(detail)
                    }
                }
            }
        } else {
            cell.setIsExpanded(isExpanded, detail: nil)
        }
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        guard offsetY > contentHeight - frameHeight - 50 else { return }
        guard currentPage < totalPages else { return }
        guard Date().timeIntervalSince(lastLoadTime) > loadInterval else { return }
        
        lastLoadTime = Date()
        self.getTripHistory(page: self.currentPage)
    }
    
    func flowLayout(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 40
        let baseHeight: CGFloat = 60
        
        if expandedIndexes.contains(indexPath) {
            return CGSize(width: width, height: baseHeight * 3)
        } else {
            return CGSize(width: width, height: baseHeight)
        }
        
    }
}

extension TripVC{
    func getTripHistory(page: Int64 = 0) {
        self.currentPage = page + 1
        
        Task { @MainActor in
            let response = await MQTTUtils.shared.publishTripHistory(
                deviceId: DeviceConfig.deviceId,
                orderBy: "end_time",
                direction: "",
                page: currentPage,
                size: sizePerPage
            )
            switch response {
            case .success(let msg):
                // 更新總頁數
                self.totalPages = msg.data!.pageInfo.totalPages
                let tripList = msg.data!.trips
                
                if currentPage == 1 {
                    self.trips = tripList
                } else {
                    // 否則 → 追加新資料
                    self.trips.append(contentsOf: tripList)
                }
    
            case .failure(let errorMsg):
                showMessageAlert(title: "載入失敗", message: errorMsg.message)
                
            case .timeout:
                showMessageAlert(title: "連線逾時", message: "請檢查網路後重試")
                
            case .rawResponse(let msg):
                print("rawResponse: \(msg)")
            }
        }
    }
    
    func getTripDetail(uuid: String, completion: @escaping (TripDetail) -> Void) {
        Task { @MainActor in
            let response = await MQTTUtils.shared.publishTripDetail(
                deviceId: DeviceConfig.deviceId,
                uuid: uuid
            )
            switch response {
            case .success(let msg):
                let detail = msg.data!
                self.tripDetails[uuid] = detail
                completion(detail)
            case .failure(let errorMsg):
                showMessageAlert(title: "載入失敗", message: errorMsg.message)
            case .timeout:
                showMessageAlert(title: "連線逾時", message: "請檢查網路後重試")
            case .rawResponse(let msg):
                print("rawResponse: \(msg)")
            }
        }
    }

}
