//
//  ZFCommunityHomeChannelBaseView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeChannelBaseView.h"

@implementation ZFCommunityHomeChannelBaseView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSMutableArray *)colorSet {
    if (!_colorSet) {
        _colorSet = [[NSMutableArray alloc] init];
    }
    return _colorSet;
}
@end
