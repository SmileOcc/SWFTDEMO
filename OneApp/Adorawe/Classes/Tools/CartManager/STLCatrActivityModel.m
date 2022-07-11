//
//  STLCatrActivityModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLCatrActivityModel.h"
#import "CartModel.h"
#import "YYText.h"

@implementation STLCatrActivityModel


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodsList" : @"goods_list",
             @"activityInfo" : @"activityInfo"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodsList" : [CartModel class],
             @"activityInfo" : [ActivityInfoModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"goodsList",
             @"activityInfo"
             ];
}
@end




////////////////////////////////

@implementation ActivityInfoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"totalDiscount" : @"total_discount",
             @"cartTips" : @"cart_tips",
             @"specialUrl" : @"specialUrl",
             @"activeId"   : @"activeId",
             @"activeName" : @"activeName",
             @"is_full_active" : @"is_full_active"
             
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"totalDiscount",
             @"cartTips",
             @"specialUrl",
             @"activeId",
             @"activeName",
             @"is_full_active",
             ];
}

- (void)compareHeaderHeight {
    
    //CGFloat saleStrW = [ActivityInfoModel saleSizeWidth];
    if (self.cartTips) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:6];
        
        NSAttributedString *titleAtt = [ActivityInfoModel activityTitle:STLToString(self.cartTips)];
        CGSize dispathSize = [STLToString(titleAtt.string) textSizeWithFont:[UIFont boldSystemFontOfSize:13]
                                                         constrainedToSize:CGSizeMake(SCREEN_WIDTH - 52, MAXFLOAT)
                                                             lineBreakMode:NSLineBreakByWordWrapping paragraphStyle:paragraphStyle];
        self.headerHeight = dispathSize.height > 30 ? 60 : 44;
    }
}

+ (CGFloat)saleSizeWidth {
    //阿语
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        return 36;
    }
    //英语
    return 30;
}

+ (NSMutableAttributedString *)activityTitle:(NSString *)title {
    
//    UIFont *font=[UIFont fontWithName:FONT_HELVETUCA size:15];
    UIFont *font=[UIFont boldSystemFontOfSize:13];
    NSMutableAttributedString *componets=[[NSMutableAttributedString alloc] init];
    NSDictionary *optoins=@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                            NSFontAttributeName:font
                            };
    NSData *data=[STLToString(title) dataUsingEncoding:NSUnicodeStringEncoding];
    NSMutableAttributedString *textPart=[[NSMutableAttributedString alloc] initWithData:data
                                                                  options:optoins
                                                       documentAttributes:nil
                                                                    error:nil];

    [componets appendAttributedString:textPart];
    return componets;
}
@end;
