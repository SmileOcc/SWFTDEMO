//
//  ZFTrackingListModel.m
//  ZZZZZ
//
//  Created by YW on 4/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFTrackingListModel.h"
#import "ZFFrameDefiner.h"

@interface ZFTrackingListModel ()
@property (assign, nonatomic) CGFloat tempHeight;
@end

@implementation ZFTrackingListModel

- (CGFloat)height {
    
    if (_tempHeight == 0) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject: [UIFont systemFontOfSize:14] forKey:NSFontAttributeName];
        
        CGFloat leftSpace = 42.0;
        CGFloat rightSpace = 16.0;
        CGFloat topSpace = 10.0;
        CGFloat midSpace = 4.0;
        CGFloat upSpace  = 25.0;
        
        CGRect statusRect = [self.status boundingRectWithSize:CGSizeMake(KScreenWidth - leftSpace - rightSpace, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
        
        CGRect dateRect = [self.ondate boundingRectWithSize:CGSizeMake(KScreenWidth - leftSpace - rightSpace, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
        
        _tempHeight = statusRect.size.height + dateRect.size.height + topSpace + upSpace + midSpace;
    }
    
    return _tempHeight;
}


@end
