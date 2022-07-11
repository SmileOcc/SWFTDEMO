//
//  STLCartAnalyticsAOP.swift
// XStarlinkProject
//
//  Created by odd on 2021/7/15.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class STLCartAnalyticsAOP: OSSVBaseeAnalyticAP {

    @objc func after_tableView(tableView:UITableView, willDisplayCell cell:UITableViewCell,indexPath:NSIndexPath) {
        
        var cartModel:CartModel?
        
        if let cartCell: OSSVCartCell = cell as? OSSVCartCell {
            cartModel = cartCell.cartModel;
            
        } else if let cartInvalidCell: OSSVCartInvalidTableCell = cell as? OSSVCartInvalidTableCell {
            cartModel = cartInvalidCell.cartModel;
        }
        
        if let cartModel: CartModel = cartModel {
            if self.goodsAnalyticsSet.contains(cartModel.goods_sn ?? "") {
                return
            }
            self.goodsAnalyticsSet.add(cartModel.goods_sn ?? "")
            
            let actionStr = OSSVAnalyticsTool.sensorsSourceString(with: self.source, sourceID: "")
            let params = ["action":actionStr ?? "",
                          "url":self.sourecDic[kAnalyticsAOPSourceID] ?? "",
                          "goods_sn":cartModel.goods_sn ?? "",
                          "currency":"USD",
                          "cat_id":cartModel.cat_id ?? "",]
            OSSVAnalyticsTool.analyticsSensorsEvent(withName: "GoodsImpression", parameters: params as [AnyHashable : Any])
        }
    }
}

extension STLCartAnalyticsAOP: OSSVAnalyticInjectsProtocol {
    func injectMenthodParams() -> [AnyHashable : Any]! {
        let params = [NSStringFromSelector(#selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:))):NSStringFromSelector(#selector(after_tableView(tableView:willDisplayCell:indexPath:))),];
        return params
    }
    
    
}
