//
//  OSSVDetailAnalyticsAOP.h
// XStarlinkProject
//
//  Created by odd on 2020/9/11.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVBaseeAnalyticAP.h"
#import "OSSVDetailRecommendCell.h"
//#import "OSSVDetailReviewCell.h"
#import "OSSVDetailReviewNewCell.h"
#import "OSSVDetailAdvertiseViewCell.h"
#import "OSSVGoodsListModel.h"
#import "OSSVDetailsHeaderView.h"


@interface OSSVDetailAnalyticsAOP : OSSVBaseeAnalyticAP
<
    OSSVAnalyticInjectsProtocol
>

@property (nonatomic, strong) NSMutableDictionary *reviewStateDic;

///标记是否需要上报推荐列表impression
@property (nonatomic,assign) BOOL needLogGoodsImpression;

- (void)reviewHadLoad:(NSString *)isLoad reviewHadData:(NSString *)hadData;
@end

