//
//  YXAlertViewController.m
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXAlertViewController.h"
#import "uSmartOversea-Swift.h"

@interface YXAlertViewController ()

@end

@implementation YXAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.containerViewColor = QMUITheme.popupLayerColor;
}

//actionSheet style 默认配置
- (void)defaultSheetConfig {
    self.sheetContentMargin = UIEdgeInsetsMake(0, 20, YXConstant.deviceScaleEqualToXStyle ? 0 : 34, 20);
    self.sheetCancelButtonMarginTop = 0;
    self.sheetSeparatorColor = [QMUITheme separatorLineColor];
    self.sheetButtonBackgroundColor = [QMUITheme foregroundColor];
    self.sheetButtonHeight = 59.0;
    self.sheetContentCornerRadius = 20.0;
    self.sheetHeaderBackgroundColor = [QMUITheme foregroundColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    self.sheetTitleAttributes = @{ NSForegroundColorAttributeName : [QMUITheme textColorLevel3], NSFontAttributeName : [UIFont systemFontOfSize:12], NSParagraphStyleAttributeName : paragraphStyle};
    self.sheetHeaderInsets = UIEdgeInsetsMake(12, 0, 12, 0);
}

@end
