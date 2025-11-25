//
//  TrackingVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit
import CoreLocation

final class TripVC: BaseVC {

    private var currentPage: Int64 = 0
    private var sizePerPage: Int64 = 10
    private var isLoadingMore = false
    private var isEnd = false
    
    // MARK: - UI Components
    private let titleLabel = PTLabel(text: "Trip History", with: .title)
    
    private let tripCollection = PTCollectionView(
        cellType: TripViewCell.self,
        reuseId: "TripViewCell"
    )
    private var trips: [TripModel] = []

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
            tripCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tripCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tripCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
       ])
    }
}

extension TripVC: PTCollectionViewDelegate{
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        let cell = cell as! TripViewCell
        let model = trips[indexPath.item]
        cell.configure(time: model.time, distance: model.distance, duration: model.duration)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        // 當滾動到距離底部 200點以內，就觸發載入下一頁
        if offsetY > contentHeight - frameHeight - 200 {
            loadMoreIfNeeded()
        }
    }
}
extension TripVC{
    func getTripHistory() {
        // 如果正在載入或沒有更多資料，就不要再呼叫
        guard !isLoadingMore || isEnd else { return }

        
        isLoadingMore = true
        currentPage += 1

        Task { @MainActor in
            let response = await MQTTUtils.shared.publishTripHistory(
                deviceId: DeviceConfig.deviceId,
                orderBy: "",
                direction: "end_time",
                page: currentPage,
                size: 0
            )
            
            isLoadingMore = false
            
            switch response {
            case .success(let msg):
                let tripList = msg.data.trips
                
                if tripList.count < sizePerPage {
                    isEnd = true
                }
                
                if currentPage == 1 {
                    self.trips = tripList
                } else {
                    // 否則 → 追加新資料
                    self.trips.append(contentsOf: tripList)
                }
                
                // 更新 CollectionView
                self.tripCollection.items = self.trips
                
            case .failure(let errorMsg):
                showMessageAlert(title: "載入失敗", message: errorMsg.message)
                
            case .timeout:
                showMessageAlert(title: "連線逾時", message: "請檢查網路後重試")
                
            case .rawResponse(let msg):
                print("rawResponse: \(msg)")
            }
        }
    }
        
    // 給 scrollView 呼叫的載入更多
    private func loadMoreIfNeeded() {
        getTripHistory()
    }
}
//
//#Preview{
//    TripVC()
//}
