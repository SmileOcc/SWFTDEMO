//
//  YXTextLinePositionModifier.h
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYText/YYText.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXTextLinePositionModifier : NSObject<YYTextLinePositionModifier>
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingBottom;
@property (nonatomic, assign) CGFloat lineHeightMultiple;
- (CGFloat)heightForLineCount:(NSUInteger)lineCount;
@end

NS_ASSUME_NONNULL_END
