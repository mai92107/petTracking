//
//  PTTextFieldCollectionViewCell.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/25.
//
import UIKit

class TripViewCell: UICollectionViewCell {
    
    private let tripInfo = PTLabel(text: "", with: .memo)
    private let arrowImage = UIImageView(
        image: UIImage(systemName: "chevron.down")
    )
    private var expandedView: TripDetailView?
    private var isExpanded: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConfig()
        setupUI()
    }
    
    private func setupConfig(){
        arrowImage.tintColor = .darkGray
        
        tripInfo.translatesAutoresizingMaskIntoConstraints = false
        arrowImage.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(tripInfo)
        contentView.addSubview(arrowImage)
    }
    
    private func setupUI() {

        NSLayoutConstraint.activate([
            tripInfo.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -16),
            tripInfo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            arrowImage.centerYAnchor.constraint(equalTo: tripInfo.centerYAnchor),
            arrowImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImage.widthAnchor.constraint(equalToConstant: 16),
            arrowImage.heightAnchor.constraint(equalToConstant: 16),
        ])
        
        contentView.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 清除展開的 view
        expandedView?.removeFromSuperview()
        expandedView = nil
        
        // 重置箭頭
        arrowImage.transform = .identity
        arrowImage.layer.removeAllAnimations()
        
        // 重置狀態
        isExpanded = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TripViewCell{
    func configure(time: String, distance: String, duration: String) {
        tripInfo.text = "\(time)  -  \(distance)km  -  \(duration)min"
    }
    
    func updateExpandedDetail(_ detail: TripDetail) {
        guard let view = expandedView else { return }
        view.updateDetail(
            startAt: detail.startAt,
            endAt: detail.endAt,
            point: detail.point,
            createdAt: detail.createdAt,
            updatedAt: detail.updatedAt
        )
    }
    
    func setIsExpanded(_ expanded: Bool, detail: TripDetail?) {
        expandedView?.removeFromSuperview()

        isExpanded = expanded
        if expanded {
            showExpandedView(detail: detail)
        }else{
            expandedView = nil
        }
        // 箭頭旋轉
        rotateArrowDirection(expanded: expanded)
    }
    
    func rotateArrowDirection(expanded: Bool){
        let fromAngle: CGFloat = expanded ? 0 : .pi
        let toAngle: CGFloat = expanded ? .pi : 0
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.5
        animation.fromValue = fromAngle
        animation.toValue = toAngle
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        self.arrowImage.layer.add(animation, forKey: "rotationAnimation")
        
        // 更新最終狀態
        self.arrowImage.transform = CGAffineTransform(rotationAngle: toAngle)
    }
    
    func showExpandedView(detail: TripDetail?){
        // 放入擴展後的view
        let detailView: TripDetailView
        if detail == nil{
            detailView = TripDetailView(loadingMsg: "Loading now...")
        }else{
            detailView = TripDetailView(
                 startAt: detail!.startAt,
                 endAt: detail!.endAt,
                 point: detail!.point,
                 createdAt: detail!.createdAt,
                 updatedAt: detail!.updatedAt
            )
        }

        detailView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailView)

        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: tripInfo.bottomAnchor, constant: 10),
            detailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            detailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            detailView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
        expandedView = detailView
    }

}
