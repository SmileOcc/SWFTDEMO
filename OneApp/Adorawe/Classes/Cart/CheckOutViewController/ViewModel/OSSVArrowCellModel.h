//
//  STLShippingMethodCellModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVBaseCellModelProtocol.h"
#import "OSSVCartCheckModel.h"

typedef NS_ENUM(NSInteger) {
    ArrowCellTypeNormal,                         ///箭头的
    ArrowCellTypeExplain_Detail,                 ///箭头-解释问号按钮-描述
    ArrowCellTypeDetail,                         ///箭头-描述
    ArrowCellTypeExplain_Button                  ///金币cell样式
}ArrowCellType;

@interface OSSVArrowCellModel : NSObject<OSSVBaseCellModelProtocol>

#pragma mark - UI显示属性
@property (nonatomic, assign) BOOL                  isDisableButton; //对金币是否可选
@property (nonatomic, assign) BOOL                  userInteractionEnabled;
@property (nonatomic, assign) ArrowCellType         cellType;
@property (nonatomic, copy) NSString                *titleContent;
///当type == ArrowCellTypeExplain_Detail || ArrowCellTypeDetail 时不能为空
@property (nonatomic, copy) NSAttributedString      *detailContent;

@property (nonatomic, copy) NSAttributedString      *subTip;
@property (nonatomic, strong) NSMutableArray        *depenDentModelList;

@property (nonatomic, strong) NSObject              *dataSourceModel;
@property (nonatomic, assign) BOOL                  isUserCoin;
@property (nonatomic, copy)  NSString               *coinSave; //兑换的金额 可以使用的
@property (nonatomic, copy)  NSString               *coinTitle1;  //Spent
@property (nonatomic, copy)  NSString               *coinTitle2;  //coins as
@property (nonatomic, copy)  NSString               *coinCount;   //金币数量


///引用
@property (nonatomic, weak) OSSVCartCheckModel *checkOutModel;

@end
