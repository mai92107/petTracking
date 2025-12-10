//
//  HomeVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/10.
//

import UIKit

final class HomeVCAuth: BaseVC {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let avatarView = UIImageView()
    private let nameLabel = UILabel()

    private var cards: [BTButton] = []

    private let cardItems: [CardItem] = [
        CardItem(icon: "location.fill", title: "裝置定位", navigateTo: TrackingVC()),
        CardItem(icon: "clock.fill", title: "歷史定位", navigateTo: TripVC()),
        CardItem(icon: "cpu.fill", title: "裝置狀態", navigateTo: DevStatusVC()),
        CardItem(icon: "gearshape.fill", title: "系統狀態", navigateTo: SysStatusVC()),
        CardItem(icon: "power", title: "登出裝置", navigateTo: nil),
        CardItem(icon: "ellipsis.circle.fill", title: "額外功能", navigateTo: nil),
        CardItem(icon: "sun.max.fill", title: "亮度調整", navigateTo: nil),
        CardItem(icon: "leaf.fill", title: "自然光調整", navigateTo: nil),
        CardItem(icon: "heart.fill", title: "收藏", navigateTo: nil),
        CardItem(icon: "heart.fill", title: "收藏", navigateTo: nil)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor

        setupUserHeader()
        setupScrollView()
        setupCards()
    }

    private func setupUserHeader() {
        avatarView.image = UIImage(named: "fatdog")
        avatarView.layer.cornerRadius = 40
        avatarView.layer.masksToBounds = true
        avatarView.contentMode = .scaleAspectFill
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.text = "使用者名稱"
        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textColor = .black.withAlphaComponent(0.85)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let headerContainer = UIView()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)
        headerContainer.addSubview(avatarView)
        headerContainer.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            // 將 headerContainer 的頂部對齊到 view 的安全區上方，並往下偏移 10pt，避免被 status bar 或 notch 遮住
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // 設定 headerContainer 的固定高度為 160pt
            headerContainer.heightAnchor.constraint(equalToConstant: 160),

            // 將 avatarView 的頂部對齊到 headerContainer 的頂部，並往下偏移 20pt
            avatarView.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 20),
            avatarView.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 80),
            avatarView.heightAnchor.constraint(equalToConstant: 80),
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 15),
            nameLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor)
        ])

    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            // ScrollView 貼在 headerContainer 底部，而不是 avatarView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 160 + 20), // headerContainer.height + 上下 padding
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupCards() {
        // 建立卡片
        cards = CardFactory.makeCards(
            items: cardItems,
            container: contentView,
            colorHexes: BentoButtonColor.colorHexes,
            target: self,
            action: #selector(cardTapped(_:))
        )

        // 排列卡片
        view.layoutIfNeeded()
        CardFactory.layoutCards(cards, in: contentView)
    }

    @objc private func cardTapped(_ sender: BTButton) {
        let item = cardItems[sender.tag]
        if item.title == "登出裝置" {
            AuthManager.shared.logout()
        } else if let vc = item.navigateTo {
            SceneNavigator.shared.goto(vc.self, from: self)
        }
    }
}

#Preview{
    HomeVCAuth()
}
