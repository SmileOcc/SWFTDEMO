//
//  YXRefreshNormalHeader.m
//  uSmartOversea
//
//  Created by ellison on 2019/1/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXRefreshNormalHeader.h"
#import "uSmartOversea-Swift.h"

@implementation YXRefreshNormalHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)prepare {
    [super prepare];
    
    [self setTitle:[YXLanguageUtility kLangWithKey:@"common_drop_refresh"] forState:MJRefreshStateIdle];
    [self setTitle:[YXLanguageUtility kLangWithKey:@"common_refreshing"] forState:MJRefreshStateRefreshing];
    [self setTitle:[YXLanguageUtility kLangWithKey:@"common_release_refresh"] forState:MJRefreshStatePulling];
    self.lastUpdatedTimeLabel.hidden = YES;
}

- (void)setStateTextColor:(UIColor *)textColor {
    self.stateLabel.textColor = textColor;
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
}

@end
