//
//  YXListNewsModel.m
//  YouXinZhengQuan
//
//  Created by JC_Mac on 2018/11/7.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXListNewsModel.h"
#import "YYText/YYTextLayout.h"
#import <YYText/NSAttributedString+YYText.h>
#import "YXToolUtility.h"

@implementation YXListNewsStockModel

@end


@implementation YXListNewsJumpTagModel

@end

@implementation YXListNewsUserModel

@end


@implementation YXListNewsModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"newsId": @"newsid",
             @"lable": @"tag",
             @"imageUrlArr": @"picture_url",
             @"date": @"release_time",
             @"feedbackArr": @"feedback",
             @"stockArr": @"stocks",
             @"type":@"news_type",
             @"algorithm":@"alg",
             @"isTop":@"is_top"
             };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"stockArr": [YXListNewsStockModel class],
             @"jump_tags": [YXListNewsJumpTagModel class],
             @"related_stocks": [YXListNewsStockModel class],
    };
}


- (void)calculateRecommendHeight {

    if (self.imageUrlArr.count > 0) {
        self.textHegith = 75;
    } else {
        CGSize size = [YXToolUtility getStringSizeWith:self.title andFont:[UIFont systemFontOfSize:16] andlimitWidth:(UIScreen.mainScreen.bounds.size.width - 32) andLineSpace:2.5];
        if (size.height > 75) {
            self.textHegith = 75;
        } else {
            self.textHegith = size.height;
        }
    }
    self.cellHeight = self.textHegith + 16 + 37;
}



@end
