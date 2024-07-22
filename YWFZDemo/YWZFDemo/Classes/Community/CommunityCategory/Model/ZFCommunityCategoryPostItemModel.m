//
//  ZFCategoryWaterPostItemModel.m
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityCategoryPostItemModel.h"
#import "YYText.h"
#import "NSString+Extended.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"

@implementation ZFCommunityCategoryPostItemModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"post_id"   : @"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"pic"             : [ZFCommunityCategoryPostPicModel class]};
}


- (void)calculateWaterFlowCellSize {
    
    CGFloat imageShowWidth = kCommunityHomeWaterfallWidth;
    self.twoColumnImageHeight = 0;
    
    if ([self.pic.width floatValue] > 0) {
        self.twoColumnImageHeight = imageShowWidth * [self.pic.height floatValue] / [self.pic.width floatValue];
    }
    
    //YY计算2行文字高度
    NSAttributedString *attContent = [[NSAttributedString alloc] initWithString:ZFToString(self.content)];
    CGFloat fontHeight = [self calculateCustomLineTextHeight:2
                                                    maxWidth:(imageShowWidth-12*2)
                                              attributedText:attContent];
    
    CGFloat bottomUIKitHeight = 6 + fontHeight + 7 + 20 +12;
    //帖子内容(避免空格)
    NSString *showTitle = [attContent.string replaceBrAndEnterChar];
    if (showTitle.length==0 || fontHeight <= 18) {
        bottomUIKitHeight = 13 + 20 + 12;
    }
    
    CGFloat allCellHeight = self.twoColumnImageHeight + bottomUIKitHeight;
    self.twoColumnCellSize = CGSizeMake(imageShowWidth, allCellHeight);
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
    CGFloat fontHeight = MAX(textLayout.textBoundingSize.height, 18);
    return fontHeight;
}

@end




@implementation ZFCommunityCategoryPostPicModel

@end
