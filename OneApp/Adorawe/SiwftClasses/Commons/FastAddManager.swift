//
//  File.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation

///快速加购工具类
class FastAddManager:NSObject{
    
    static let shared = FastAddManager()

    private override init(){
        super.init()
        controller = UIViewController.currentTop()
    }
    
    let baseInfoModel = OSSVDetailsViewModel()
    var sourceType:STLAppsflyerGoodsSourceType!
    
    weak var controller:UIViewController!
    
    var detailSheet: STLActionSheet?{
        get{
            if let sheet = FastAddManager.sheet {
                return sheet
            }else{
                FastAddManager.sheet = createSheet()
                return  FastAddManager.sheet
            }
        }
    }
    
    @objc static var sheet:STLActionSheet?
    
    func createSheet()-> STLActionSheet{
        let detailSheetY:CGFloat = Bool.kIS_IPHONEX ? 88 : 64
        let detailSheet = STLActionSheet(frame: CGRect(x: 0, y: -detailSheetY, width: .screenWidth, height: .screenHeight + detailSheetY))
        detailSheet.type = .add;
        detailSheet.hasFirtFlash = true
        detailSheet.isListSheet = true
        detailSheet.addCartType = 1
        detailSheet.screenGroup = "New_Pop-ups_"
        detailSheet.position    = "New_Pop-ups"
        detailSheet.attributeBlock = {[weak self] goodId,wid in
            self?.requesData(goodsId: goodId ?? "", wid: wid ?? "",controller: self!.controller)
        }
        
        detailSheet.attributeNewBlock = {[weak self] goodId,wid,specailId in
            self?.requesData(goodsId: goodId ?? "", wid: wid ?? "",specialID: specailId ?? "",controller: self!.controller)
        }

        detailSheet.attributeHadManualSelectSizeBlock = {[weak self] in
            self?.baseInfoModel.hadManualSelectSize = true
        }

        detailSheet.goNewToDetailBlock = {[weak self] goodsId,wid,specialId,goodsImageUrl in
            let detailVC = OSSVDetailsVC()
            detailVC.wid = wid
            detailVC.goodsId = goodsId
            detailVC.specialId = specialId
            detailVC.sourceType = self?.sourceType ?? .home
            detailVC.coverImageUrl = goodsImageUrl
            self!.controller.navigationController?.pushViewController(detailVC, animated: true)
            detailSheet.dismiss()
        }
        return detailSheet
    }
    
    func requesData(goodsId:String,wid:String,specialID:String? = "",controller:UIViewController,collextionView:UICollectionView? = nil) {
        
        collextionView?.allowsSelection = false
        
        let params = [
            "goods_id":goodsId,
            "loadState":STLRefresh,
            "wid":wid,
            "specialId":STLToString(specialID),
        ]
        self.controller = controller
        baseInfoModel.requestNetworkOnly(params as [AnyHashable : Any]) {[weak self] obj in
            collextionView?.allowsSelection = true
            if let obj = obj as? OSSVDetailsBaseInfoModel,
               let sheet = self?.detailSheet{
                
                sheet.baseInfoModel = obj
                sheet.hadManualSelectSize = true
                sheet.addCartAnimationTop(0, moveLocation: .zero, showAnimation: false)
                controller.tabBarController!.view.addSubview(sheet)
                UIView.animate(withDuration: 0.25) {
                    sheet.shouAttribute()
                    sheet.sourceType = self?.sourceType ?? .home
                    sheet.type = .add
                }
            }
        } failure: { _ in
            collextionView?.allowsSelection = true
        }
        
    }
}
