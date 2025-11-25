//
//  TrackingVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit
import CoreLocation

final class TripVC: BaseVC {

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
}

extension TripVC{
    func getTripHistory(){
        Task { @MainActor in
            let response = await MQTTUtils.shared.publishTripHistory(
                deviceId: DeviceConfig.deviceId,
                orderBy: "",
                direction: "end_time",
                page: 0,
                size: 0)
            
            switch response {
            case .success(let msg):
                let pageInfo = msg.data.pageInfo      // 📌 取得分頁資訊
                let tripList = msg.data.trips     // 📌 取得紀錄清單

                self.trips = tripList
                self.tripCollection.items = tripList
                
            case .failure(let errorMsg):
                // 自動彈出後端錯誤訊息！
                showMessageAlert(title: "歷史旅程查詢失敗", message: errorMsg.message)
                
            case .timeout:
                showMessageAlert(title: "連線逾時", message: "請檢查網路後重試"
                )
            case .rawResponse(let msg):
                print("rawResponse: " + msg)
            }
        }
    }
}
//
//#Preview{
//    TripVC()
//}
