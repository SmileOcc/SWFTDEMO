//
//  YXMyAssetsDetailSecretLabel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/7.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXMyAssetsDetailSecretLabel: QMUILabel {

    @objc static let hideValueNotificationName = "yx_my_assets_detail_hide_value_noti"

    var value: String? {
        didSet {
            if shouldShowStar {
                self.text = "****"
            } else {
                self.text = value
            }
        }
    }

    var attributedValue: NSAttributedString? {
        didSet {
            if shouldShowStar {
                self.attributedText = NSAttributedString.init(string: "****")
            } else {
                self.attributedText = attributedValue
            }
        }
    }

    var shouldShowStar = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        refreshValueText()

        _ = NotificationCenter.default.rx.notification(NSNotification.Name(YXMyAssetsDetailSecretLabel.hideValueNotificationName))
            .subscribe(onNext: { [weak self] _ in
                self?.refreshValueText()
            }).disposed(by: rx.disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func changeText(noti: Notification) {
        self.shouldShowStar = YXMyAssetsDetailStatisticsView.assetHidden

        if shouldShowStar {
            self.text = "****"
        } else {
            if let value = self.value {
                self.text = value
            } else if let attValue = self.attributedValue {
                self.attributedText = attValue
            }
        }
    }

    private func refreshValueText() {
        self.shouldShowStar = YXMyAssetsDetailStatisticsView.assetHidden

        if YXMyAssetsDetailStatisticsView.assetHidden {
            self.text = "****"
        } else {
            if let value = self.value {
                self.text = value
            } else if let attValue = self.attributedValue {
                self.attributedText = attValue
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
