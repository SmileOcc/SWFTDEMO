//
//  ZFSettingCellModel.swift
//  ZZZZZ
//
//  Created by YW on 2019/7/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

import UIKit

class ZFSettingCellModel: NSObject {

    var detailTitle: String! = ""
    var imagePath: String! = ""
    var title: String! = ""
    var cellAccessoryType: UITableViewCell.AccessoryType = UITableViewCell.AccessoryType.none
    var cellSelectHandle:((ZFSettingCellModel)->(Void))?
    var detailTitleColor: UIColor! = ZFSwiftColorDefine.RGBColor(_red: 153, _green: 153, _blue: 153, _alpha: 1.0)
}
