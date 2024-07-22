//
//  ZFCommunityTopicDetailListModel.m
//  ZZZZZ
//
//  Created by DBP on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailListModel.h"
#import "ZFCommunityPictureModel.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "NSString+Extended.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "NSStringUtils.h"

#import "ZFCommunityImageLayoutView.h"

@implementation ZFCommunityTopicDetailListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"reviewPic" : [ZFCommunityPictureModel class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"reviewsId"    :   @"reviewId",
             @"userId"       :   @"userId",
             @"avatar"       :   @"avatar",
             @"nickname"     :   @"nickname",
             @"addTime"      :   @"add_time",
             @"isFollow"     :   @"isFollow",
             @"content"      :   @"content",
             @"reviewPic"    :   @"reviewPic",
             @"likeCount"    :   @"likeCount",
             @"isLiked"      :   @"isLiked",
             @"topicList"    :   @"topicList",
             @"replyCount"   :   @"replyCount",
             @"identify_type":   @"identify_type",
             @"identify_icon":   @"identify_icon",
             };
}


// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"reviewsId",
             @"userId",
             @"avatar",
             @"nickname",
             @"addTime",
             @"isFollow",
             @"content",
             @"reviewPic",
             @"likeCount",
             @"isLiked",
             @"topicList",
             @"replyCount",
             @"identify_type",
             @"identify_icon",
             ];
}


#pragma mark -===========计算Cell大小===========

- (void)calculateCommonFlowCellSize {
    
    //一个Model只初始化一次帖子富文本
    [self setupCommonAttributedContent];
    
    CGFloat cellWidth  = KScreenWidth;
    
    CGFloat allHeight = 0;
    // 用户信息条高度
    CGFloat topUserViewHeight = 73;
    // 图片容器高度
    CGFloat imagViewHeight = [ZFCommunityImageLayoutView heightContentImagePaths:self.reviewPic contentWidth:cellWidth - 12 * 2 leadSpace:0 trailSpace:0 fixedSpace:10];
    // 评论内容高度
    CGFloat commentHeight = 0;
    
    // 评论与图片间间隙
    CGFloat commentTopSpace = 8;
    CGFloat commentBottomSpace = 8;
    CGFloat separateHeight = 12;
    // 底部操作视图高度
    CGFloat bottomViewHeight = kTopicDetailBottomHeight;

    //YY计算2行文字高度
    commentHeight = [self calculateCustomLineTextHeight:2
                                                       maxWidth:(KScreenWidth - 24)
                                                 attributedText:self.contentAttributedText];
    
    //帖子内容(避免空格)
    NSString *showTitle = [self.contentAttributedText.string replaceBrAndEnterChar];
    self.commentHeight = commentHeight;
    YWLog(@"---imgH %f -- %f",imagViewHeight,commentHeight);

    if (showTitle.length == 0) {
        commentHeight = 0;
        self.commentHeight = 0;
        commentBottomSpace = 0;
    }
    YWLog(@"--- %f \n",commentHeight);

    allHeight = topUserViewHeight + imagViewHeight + commentHeight + bottomViewHeight +  commentTopSpace + separateHeight + commentBottomSpace;
    self.oneColumnCellSize = CGSizeMake(cellWidth, allHeight);
}

- (void)calculateWaterFlowCellSize {
    
    //一个Model只初始化一次帖子富文本
    [self setupAttributedContent];
    
    CGFloat cellWidth  = (KScreenWidth - 3 * 12) / 2.0;
    CGFloat bottomViewHeight = kTopicDetailBottomHeight;
    CGFloat allHeight = 0;
    
    NSArray *reviewPics = self.reviewPic;
    if (reviewPics.count > 0) {
        ZFCommunityPictureModel *picModel = (ZFCommunityPictureModel *)reviewPics.firstObject;
        if ([picModel.bigPicWidth floatValue] > 0) {
            allHeight = cellWidth * [picModel.bigPicHeight floatValue] / [picModel.bigPicWidth floatValue];
        }
    }

    //YY计算2行文字高度
    CGFloat commentHeight = [self calculateCustomLineTextHeight:2
                                                  maxWidth:((KScreenWidth - 36) / 2.0 - 24)
                                            attributedText:self.contentAttributedText];
    
    //帖子内容(避免空格)
    NSString *showTitle = [self.contentAttributedText.string replaceBrAndEnterChar];
    if (showTitle.length==0) {
        commentHeight = 12;
    } else {
        commentHeight += 6;
    }
    YWLog(@"--- %f",commentHeight);

    self.commentHeight = commentHeight;
    allHeight += bottomViewHeight + commentHeight;
    self.twoColumnCellSize = CGSizeMake((KScreenWidth - 3 * 12) / 2.0, allHeight);
}


- (void)setupCommonAttributedContent
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
    content.yy_font = ZFFontSystemSize(14.0);
    content.yy_color = ZFCOLOR(102, 102, 102, 1.0);
    
    NSArray <NSValue *> *rangeValues = [NSStringUtils matchString:content.string reg:RegularExpression matchOptions:NSMatchingReportProgress];
    [rangeValues enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [obj rangeValue];
        [content yy_setColor:ZFC0x3D76B9() range:range];
        [content yy_setTextHighlightRange:range color:ZFC0x3D76B9() backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSString *labName = [content.string substringWithRange:range];
            if (self.touchTopicAttrTextBlcok) {
                self.touchTopicAttrTextBlcok(labName);
            }
        }];
    }];
    
    if ([SystemConfigUtils isRightToLeftShow]) {
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentRight;
        [content addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, content.length)];
    }
    self.contentAttributedText = content;
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
