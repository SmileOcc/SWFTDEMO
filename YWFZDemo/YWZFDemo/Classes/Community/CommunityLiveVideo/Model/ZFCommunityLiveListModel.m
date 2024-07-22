//
//  ZFCommunityLiveListModel.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveListModel.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "NSString+Extended.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "NSStringUtils.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"

static CGFloat kLiveListCellBottomHeight = 40;

@implementation ZFCommunityLiveListModel


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"idx"   : @"id",
              };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"ios_hot"             : [ZFCommunityLiveVideoRedNetModel class],
             @"spare_channel_id"    : [ZFCommunityLiveRouteModel class]
             };
}

- (BOOL)isFull {
    if (self.pattern == 1) {
        return NO;
    } else {
        return YES;
    }
}

- (void)calculateCommonFlowCellSize {
    
    //一个Model只初始化一次帖子富文本
    [self setupCommonAttributedContent];
    [self setupLiveStateAttributedText];
    
    CGFloat cellWidth  = KScreenWidth - 12 * 2;
    
    CGFloat allHeight = 0;

    // 图片容器高度
    CGFloat imagViewHeight = 0;
    // 评论内容高度
    CGFloat commentHeight = 0;
    
    // 评论与图片间间隙
    CGFloat commentTopSpace = 8;
    CGFloat commentBottomSpace = 0;
    // 底部操作视图高度
    CGFloat bottomViewHeight = kLiveListCellBottomHeight;
    
    if ([self.ios_pic_width floatValue] > 0) {
        imagViewHeight = cellWidth * [self.ios_pic_height floatValue] / [self.ios_pic_width floatValue];
    }
    
    //YY计算2行文字高度
    commentHeight = [self calculateCustomLineTextHeight:2
                                               maxWidth:KScreenWidth - 12 * 2 - 8 * 2
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
    
    allHeight = imagViewHeight + commentHeight + bottomViewHeight +  commentTopSpace + commentBottomSpace;
    self.oneColumnCellSize = CGSizeMake(cellWidth, allHeight);
    self.oneColumnImageHeight = imagViewHeight;
}


#pragma mark - private methods
- (NSString*)timer:(NSString*)timer {
    NSInteger intervalTime = [timer integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:intervalTime];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM/dd/yyyy HH:mm";
    NSString *time = [df stringFromDate:date];
    return time;
}

- (void)setupLiveStateAttributedText {
    if (self.liveStateAttributedText) return;
    
    if ([self.type integerValue] == ZFCommunityLiveStateLiving) {
        
        NSString *titleStr = [NSString stringWithFormat:@"%@  |",ZFLocalizedString(@"Community_Lives_Livestreams", nil)];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",titleStr, [self timer:ZFToString(self.start_time)]]];
        
        CGFloat rangeX = 0;
        text.yy_font = [UIFont systemFontOfSize:12.0f];
        text.yy_color = ZFC0xFFFFFF();
        [text yy_setFont:[UIFont systemFontOfSize:14] range:NSMakeRange(rangeX, titleStr.length)];
        self.liveStateAttributedText = text;
        
    } else if ([self.type integerValue] == ZFCommunityLiveStateReady) {
        
        NSString *titleStr = ZFLocalizedString(@"Community_Lives_Live_Start_In", nil);
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ \n%@",titleStr, [self timer:ZFToString(self.start_time)]]];
        
        CGFloat rangeX = 0;
        text.yy_font = [UIFont systemFontOfSize:12.0f];
        text.yy_color = ZFC0xFFFFFF();
        [text yy_setFont:[UIFont systemFontOfSize:14] range:NSMakeRange(rangeX, titleStr.length)];
        self.liveStateAttributedText = text;
    }
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

- (ZFCommunityLivePlatform)currentLivePlatform {
    NSString *platform = ZFToString(self.live_platform);
    if ([platform isEqualToString:@"1"]) {
        return ZFCommunityLivePlatformFacebook;
    } else if ([platform isEqualToString:@"2"]) {
        return ZFCommunityLivePlatformYouTube;
    } else if ([platform isEqualToString:@"3"]) {
        return ZFCommunityLivePlatformZego;
    } else if ([platform isEqualToString:@"4"]) {
        return ZFCommunityLivePlatformThirdStream;
    }
    return ZFCommunityLivePlatformUnknow;
}
@end
