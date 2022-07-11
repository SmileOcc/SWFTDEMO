//
//  OSSVHomeMainAnalyseAP.h
// XStarlinkProject
//
//  Created by odd on 2020/9/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVBaseeAnalyticAP.h"
#import "OSSVAnalyticInjectsManager.h"
#import "OSSVAnalyticInjectsProtocol.h"

#import "OSSVPrGoodsSPecialCCell.h"
#import "OSSVProGoodsCCellModel.h"
#import "OSSVHomeGoodsListModel.h"
#import "CustomerLayoutSectionModuleProtocol.h"

#import "OSSVAsinglesAdvCCell.h"
#import "OSSVCountsDownCCell.h"
#import "OSSVHomeTopiicCCell.h"
#import "OSSVScrollTitlesCCell.h"
#import "OSSVHomeCartCCell.h"
#import "OSSVThemesChannelsCCell.h"
#import "OSSVScrollAdvBannerCCell.h"
#import "OSSVSevenAdvBannerCCell.h"
#import "OSSVHomeCycleSysTipCCell.h"
#import "OSSVFastSalesCCell.h"
#import "OSSVScrolllGoodsCCell.h"
#import "OSSVHomeAdvBannerCCell.h"
#import "OSSVScrollCCell.h"

#import "OSSVScrollAdvCCellModel.h"
#import "OSSVFlasttSaleCellModel.h"
#import "OSSVSevenAdvCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *kHomeDiscoverSubTabIndex = @"kHomeDiscoverSubTabIndex";
@interface OSSVHomeMainAnalyseAP : OSSVBaseeAnalyticAP
<
    OSSVAnalyticInjectsProtocol
>

@property (nonatomic,strong) NSMutableArray <id<CustomerLayoutSectionModuleProtocol>> *dataSourceList;
@end

NS_ASSUME_NONNULL_END
