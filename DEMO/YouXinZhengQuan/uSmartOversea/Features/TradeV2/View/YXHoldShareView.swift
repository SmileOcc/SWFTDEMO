//
//  YXHoldShareView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/6/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

@objc enum HoldShareType: Int {
    case hold   // 持仓
    case asset  // 资产
    case order  // 订单
}

class YXHoldShareView: YXHoldShareCommonView {

    @objc class func showShareView(type: HoldShareType, exchangeType: Int, model: Any?) {
        let longUrl = YXQRCodeHelper.appQRString(shareId: "pages", bizid: "portfolio")
        let hud = YXProgressHUD.showLoading(nil)
        YXShortUrlRequestModel.startRequest(longUrl: longUrl) { qrcodeUrlString  in
            hud.hide(animated: true)

            let shareView = YXHoldShareView.init(frame: UIScreen.main.bounds, shareType: type, exchangeType: exchangeType, qrcodeUrlString: qrcodeUrlString)
            if let holdStockModel = model as? YXAccountAssetHoldListItem {
                shareView.holdStockModel = holdStockModel
            } else if let assetModel = model as? YXAccountAssetData {
                shareView.assetData = assetModel
            } else if let orderModel = model as? YXOrderModel {
                shareView.orderModel = orderModel
            } else if let orderDetailModel = model as? YXOrderDetailData {
                shareView.orderDetailModel = orderDetailModel
            }

            shareView.showShareView()
        }
    }

    @objc var holdStockModel: YXAccountAssetHoldListItem? {
        didSet {
            for contentView in contentViews {
                if let view = contentView as? YXHoldShareContentView {
                    view.holdStockModel = holdStockModel
                }
            }
        }
    }

    var assetData: YXAccountAssetData? {
        didSet {
            for contentView in contentViews {
                if let view = contentView as? YXHoldShareContentView {
                    view.assetModel = assetData
                }
            }
        }
    }

    var orderModel: YXOrderModel? {
        didSet {
            orderId = orderModel?.entrustId

            for contentView in contentViews {
                if let view = contentView as? YXHoldShareContentView {
                    view.orderModel = orderModel
                }
            }
        }
    }

    var orderDetailModel: YXOrderDetailData? {
        didSet {
            orderId = orderDetailModel?.entrustId

            for contentView in contentViews {
                if let view = contentView as? YXHoldShareContentView {
                    view.orderDetailModel = orderDetailModel
                }
            }
        }
    }

    var exchangeType: Int = 0
    var qrcodeUrlString: String = ""

    @objc init(frame: CGRect, shareType: HoldShareType, exchangeType: Int, qrcodeUrlString: String) {
        super.init(frame: frame, shareType: shareType)

        self.backgroundColor = UIColor.qmui_color(withHexString: "#262A55")

        self.exchangeType = exchangeType
        self.qrcodeUrlString = qrcodeUrlString
        
        imageViewWidth = YXConstant.screenWidth - 22 * 2
        imageViewHeight = imageViewWidth * 468.0 / 323.0

        contentViews.removeAll()

        var shareSubTypes: [HoldShareSubType]

        switch shareType {
        case .hold:
            shareSubTypes = [.normalAmount, .normalPercent]
        case .asset:
            shareSubTypes = [.assetDailyAmount, .assetDailyPercent, .assetTotalAmount]
        case .order:
            shareSubTypes = [.order]
        }

        for subType in shareSubTypes {
            let contentView = YXHoldShareContentView(frame: CGRect(x: 0, y: 0, width: 323, height: 468),
                                                     shareType: self.shareType,
                                                     exchangeType: self.exchangeType,
                                                     qrcodeUrlString: self.qrcodeUrlString,
                                                     subShareType: subType)
            contentViews.append(contentView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXHoldShareContentBottomView: UILabel {

    private var title = ""
    private var detail = ""
    private var separator = "\n"

    init(title: String, detail: String, separator: String) {
        super.init(frame: .zero)
        self.title = title
        self.detail = detail
        self.separator = separator
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        self.numberOfLines = 0
//        let paragraph = NSMutableParagraphStyle()
//        paragraph.lineSpacing = 2

        let attribtedText = NSMutableAttributedString(
            string: title,
            attributes: [
                .font: UIFont.systemFont(ofSize: 10, weight: .medium),
                .foregroundColor: UIColor.qmui_color(withHexString: "#2A2A34") as Any,
//                .paragraphStyle: paragraph
            ]
        )

        let attribtedSeparator = NSAttributedString(
            string: separator,
            attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: UIColor.qmui_color(withHexString: "#888996") as Any]
        )
        attribtedText.append(attribtedSeparator)

        let attribtedDetail = NSAttributedString(
            string: detail,
            attributes: [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.qmui_color(withHexString: "#888996") as Any]
        )
        attribtedText.append(attribtedDetail)

        self.attributedText = attribtedText
    }

}
