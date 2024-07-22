
//
//  ZFCommunityAccountShowsModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountShowsModel.h"
#import "NSString+Extended.h"
#import "NSDate+ZFExtension.h"
#import "YYTextLayout.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "NSStringUtils.h"
#import "NSString+Extended.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"

@implementation ZFCommunityAccountShowsModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"nickName" : @"nickname",
             @"userId" : @"userId"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"reviewPic" : [ZFCommunityPictureModel class],
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"addTime",
             @"avatar",
             @"content",
             @"isFollow",
             @"isLiked",
             @"likeCount",
             @"nickName",
             @"replyCount",
             @"reviewId",
             @"reviewPic",
             @"userId",
             @"topicList",
             @"identify_type",
             @"identify_icon",
             ];
}

#pragma mark -===========计算Cell大小===========

/**
 * 利用约束计算Cell大小
 */
- (void)calculateCellSize
{
    //一个Model只初始化一次帖子富文本
    [self setupAttributedContent];
    
    if (self.twoColumnCellSize.width != 0.0 && self.twoColumnCellSize.height != 0.0) return;
    
    //计算瀑布流Cell高度
    [self calculateWaterFlowCellSize];
}

/**
 * 计算瀑布流Cell高度
 */
- (void)calculateWaterFlowCellSize
{
    CGFloat imageShowWidth = (KScreenWidth - 10*3) / 2;
    
    //瀑布流帖子布局
    //YY计算2行文字高度
    CGFloat fontHeight = [self calculateCustomLineTextHeight:2
                                                    maxWidth:(imageShowWidth-12*2)
                                              attributedText:self.contentAttributedText];
    
    CGFloat bottomUIKitHeight = 6 + fontHeight + 7 + 20 + 12;
    //帖子内容(避免空格)
    NSString *showTitle = [self.contentAttributedText.string replaceBrAndEnterChar];
    if (showTitle.length==0) {
        bottomUIKitHeight = 7 + 20 + 12;
    }
    
    //取帖子的第一张图片的size
    if (self.reviewPic.count>0) {
        ZFCommunityPictureModel *reviewPicModel = self.reviewPic[0];
        CGFloat width = [reviewPicModel.bigPicWidth floatValue];
        CGFloat height = [reviewPicModel.bigPicHeight floatValue];
        
        if (width <= 0.0) width = imageShowWidth;
        if (height <= 0.0) height = imageShowWidth;
        
        self.twoColumnImageHeight = (imageShowWidth * height) / width;
        CGFloat allCellHeight = self.twoColumnImageHeight + bottomUIKitHeight;
        self.twoColumnCellSize = CGSizeMake(imageShowWidth, allCellHeight);
        
    } else {
        self.twoColumnImageHeight = imageShowWidth;
        CGFloat allCellHeight = self.twoColumnImageHeight + bottomUIKitHeight;
        self.twoColumnCellSize = CGSizeMake(imageShowWidth, allCellHeight);
    }
}

/**
 * 在cell中时时计算这些会有性能消耗
 */
- (void)setupAttributedContent
{
    //一个Model只初始化一次帖子富文本
    if (self.contentAttributedText) return;
    
    NSMutableString *contentStr = [NSMutableString string];
    if (self.topicList.count>0) {
        for (NSString *str in self.topicList) {
            [contentStr appendString:[NSString stringWithFormat:@"%@ ", str]];
        }
    }
    
    if (self.content) {
        [contentStr appendString:self.content];
    }
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:contentStr];
    content.yy_font = ZFFontSystemSize(12.0);
    content.yy_color = ZFCOLOR(102, 102, 102, 1.0);
    
    NSArray <NSValue *> *rangeValues = [NSStringUtils matchString:content.string reg:RegularExpression matchOptions:NSMatchingReportProgress];
    [rangeValues enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [obj rangeValue];
        [content yy_setColor:ZFCOLOR(255, 168, 0, 1.0) range:range];
        [content yy_setTextHighlightRange:range color:ZFCOLOR(255, 168, 0, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSString *labName = [content.string substringWithRange:range];
            if (self.touchTopicAttrTextBlcok) {
                self.touchTopicAttrTextBlcok(labName);
            }
        }];
    }];
    
//    NSArray *cmps = [contentStr componentsMatchedByRegex:RegularExpression];
//
//    [cmps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSRange range = [contentStr rangeOfString:cmps[idx]];
//        [content yy_setColor:ZFCOLOR(102, 102, 102, 1.0) range:range];
//        [content yy_setTextHighlightRange:range color:ZFCOLOR(102, 102, 102, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//            NSString *labName = cmps[idx];
//            if (self.touchTopicAttrTextBlcok) {
//                self.touchTopicAttrTextBlcok(labName);
//            }
//        }];
//    }];
    
    if ([SystemConfigUtils isRightToLeftShow]) {
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentRight;
        [content addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, content.length)];
    }
    self.contentAttributedText = content;
}

/**
 * 计算指定行文字高度
 */
- (CGFloat)calculateCustomLineTextHeight:(NSInteger)limiteLine
                                maxWidth:(CGFloat)maxWidth
                          attributedText:(NSAttributedString *)attributedText
{
    YYTextContainer *container = [YYTextContainer new];
    container.size = CGSizeMake(maxWidth, CGFLOAT_MAX);
    YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
    modifier.fixedLineHeight = 18;//行高
    container.linePositionModifier = modifier;
    container.maximumNumberOfRows = limiteLine;
    container.truncationType = YYTextTruncationTypeEnd;
    
    YYTextLayout *textLayout =[YYTextLayout layoutWithContainer:container text:attributedText];
    CGFloat fontHeight = MAX(textLayout.textBoundingSize.height, 20);
    return fontHeight;
}

@end
