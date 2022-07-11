//
//  OSSVRefreshsAutosNormalFooter.m
// XStarlinkProject
//
//  Created by odd on 2020/11/23.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVRefreshsAutosNormalFooter.h"

@implementation OSSVRefreshsAutosNormalFooter

- (void)prepare {
    [super prepare];
    self.stateLabel.textColor = OSSVThemesColors.col_999999;
    self.stateLabel.font = [UIFont systemFontOfSize:13];
    
    // 重写文字
    [self setTitle:@"" forState:MJRefreshStateIdle];
    [self setTitle:STLLocalizedString_(@"MJRefreshAutoFooterRefreshingText", nil) forState:MJRefreshStateRefreshing];
    [self setTitle:STLLocalizedString_(@"MJRefreshAutoFooterNoMoreDataText", nil) forState:MJRefreshStateNoMoreData];
}
@end
