//
//  YXOrderErrorAlertController.m
//  YouXinZhengQuan
//
//  Created by rrd on 2019/1/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXOrderErrorAlertController.h"
#import "uSmartOversea-Swift.h"

@interface YXOrderErrorAlertController ()

@end

@implementation YXOrderErrorAlertController

+(YXOrderErrorAlertController *)alertControllerWithTitle:(NSString *)title content:(NSString *)content subContent:(NSString *)subContent {
    
    YXOrderErrorAlertView *view = [[YXOrderErrorAlertView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth-52, 215)];
    view.layer.cornerRadius = 2;
    view.clipsToBounds = YES;
    view.title = title;
    view.content = content;
    view.subContent = subContent;
    view.backgroundColor = [QMUITheme foregroundColor];
    [view refreshUI];
    YXOrderErrorAlertController *alertController = [YXOrderErrorAlertController alertControllerWithAlertView:view preferredStyle:TYAlertControllerStyleAlert];
    
    return alertController;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YXOrderErrorAlertView *alertView = (YXOrderErrorAlertView *)self.alertView;
    
    @weakify(self)    
    [[[alertView.confirmBtn  rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        
        [self dismissViewControllerAnimated:YES];
    }];

}



@end
