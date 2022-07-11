//
//  OSSVSwitchCellModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBaseCellModelProtocol.h"
#import "RateModel.h"
#import "OSSVPointsModel.h"
#import "OSSVCartCheckModel.h"

typedef NS_ENUM(NSInteger) {
    SwitchCellTypeNormal,                  ///普通switch
    SwitchCellTypeExplain                  ///问号解释的switchh cell
}SwitchCellType;

@interface OSSVSwitchCellModel : NSObject<OSSVBaseCellModelProtocol>

///依赖属性 <因为可能有多仓的缘故，所以需要用数组保存依赖属性>
@property (nonatomic, strong) NSMutableArray *depenDentModelList;
///依赖类型
@property (nonatomic, assign) TotalDetailType depenType;

///显示的类型
@property (nonatomic, assign) SwitchCellType cellType;

@property (nonatomic, assign) BOOL switchStatus;

#pragma mark - 视图显示数据,也可用model来表示
@property (nonatomic, copy) NSString *titleContent;
@property (nonatomic, copy) NSString *valueContent;

#pragma mark - 数据源
@property (nonatomic, strong) NSObject *dataSourceModel;
@property (nonatomic, strong) RateModel *rateModel;
@property (nonatomic, strong) OSSVCartCheckModel *checkModel;
@end
