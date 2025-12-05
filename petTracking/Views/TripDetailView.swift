//
//  TripDetailView.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/26.
//

import UIKit

class TripDetailView: UIView {
    
    private let startLabel: PTLabel
    private let endLabel: PTLabel
    private let pointLabel: PTLabel
    private let createLabel: PTLabel
    private let updateLabel: PTLabel

    // 初始化方法，將資料傳入
    init(startAt: String, endAt: String, point: Int, createdAt: String, updatedAt: String) {

        self.startLabel = PTLabel(text: "開始時間: \(startAt)", with: .memo)
        self.endLabel = PTLabel(text: "結束時間: \(endAt)", with: .memo)
        self.pointLabel = PTLabel(text: "採集數量: \(point)", with: .memo)
        self.createLabel = PTLabel(text: "建立時間: \(createdAt)", with: .memo)
        self.updateLabel = PTLabel(text: "更新時間: \(updatedAt)", with: .memo)
        
        super.init(frame: .zero)
        
        setupConfig()
        setupUI()
    }
    
    init(loadingMsg: String){
        self.startLabel = PTLabel(text: "", with: .memo)
        self.endLabel = PTLabel(text: "", with: .memo)
        self.pointLabel = PTLabel(text: loadingMsg, with: .memo)
        self.createLabel = PTLabel(text: "", with: .memo)
        self.updateLabel = PTLabel(text: "", with: .memo)
        super.init(frame: .zero)
        
        setupConfig()
        setupUI()
    }
    
    private func setupConfig() {
        [startLabel, endLabel, pointLabel, createLabel, updateLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setupUI() {
        let gap: CGFloat = 8
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            startLabel.topAnchor.constraint(equalTo: topAnchor),
            startLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            endLabel.topAnchor.constraint(equalTo: startLabel.bottomAnchor, constant: gap),
            endLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            pointLabel.topAnchor.constraint(equalTo: endLabel.bottomAnchor, constant: gap),
            pointLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            createLabel.topAnchor.constraint(equalTo: pointLabel.bottomAnchor, constant: gap),
            createLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            updateLabel.topAnchor.constraint(equalTo: createLabel.bottomAnchor, constant: gap),
            updateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
        ])
    }
    
    func updateDetail(startAt: String, endAt: String, point: Int, createdAt: String, updatedAt: String) {
        self.startLabel.text = "開始時間: \(startAt)"
        self.endLabel.text = "結束時間: \(endAt)"
        self.pointLabel.text = "採集數量: \(point)"
        self.createLabel.text = "建立時間: \(createdAt)"
        self.updateLabel.text = "更新時間: \(updatedAt)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
