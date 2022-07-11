//
//  GoodsDetailsListModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsListModel.h"

@implementation OSSVDetailsListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodsBaseInfo" : @"BaseInfo",
             @"recommend"     : @"recommend",
             @"review"        : @"review",
             @"banner"        : @"banner",
             @"request_id" : @"recommend.request_id"
             };
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"banner"        : [OSSVAdvsEventsModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"goodsBaseInfo",
             @"recommend",
             @"review",
             @"banner",
             @"request_id"
             ];
}

//- (OSSVReviewsModel *)reviewsModel {
//    if (!_reviewsModel) {
//        _reviewsModel = [[OSSVReviewsModel alloc] init];
//    }
//    return _reviewsModel;
//}


- (void)configureTopBannerWeight {
    CGFloat width = 0.0;
    if (STLJudgeNSArray(self.goodsBaseInfo.pictureListArray)) {
        OSSVDetailPictureArrayModel *firtPictureModel = self.goodsBaseInfo.pictureListArray.firstObject;
        CGFloat imgW = [firtPictureModel.img_width floatValue];
        CGFloat imgH = [firtPictureModel.img_height floatValue];
        
        STLLog(@"----%f",SCREEN_WIDTH);
        if (imgH > 0.0) {
            width = SCREEN_WIDTH * imgW / imgH;
        }
    }
    if (width <= 0.0 || width >= SCREEN_WIDTH) {
        width = SCREEN_WIDTH;
    }
    self.goodsImageWidth = width;
}
@end
