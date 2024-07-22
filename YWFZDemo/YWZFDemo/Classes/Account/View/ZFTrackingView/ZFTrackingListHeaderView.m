//
//  ZFTrackingListHeaderView.m
//  ZZZZZ
//
//  Created by YW on 4/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFTrackingListHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFTrackingPackageModel.h"
#import "ZFWebViewViewController.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFTrackingListHeaderView ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel   *shipNameLabel;
@property (nonatomic, strong) UILabel   *trackingNumLabel;
//@property (nonatomic, strong) UIView    *line;
@end

@implementation ZFTrackingListHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.bounds = CGRectMake(0, 0, KScreenWidth, 60);
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark -<ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
    [self addSubview:self.shipNameLabel];
    [self addSubview:self.trackingNumLabel];
//    [self addSubview:self.line];
}

- (void)zfAutoLayoutView {
    [self.trackingNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).mas_equalTo(12);
        make.top.equalTo(self.mas_top).offset(20);
    }];
    
    [self.shipNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.trackingNumLabel);
        make.top.equalTo(self.trackingNumLabel.mas_bottom).offset(8);
    }];
    
//
//    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.bottom.equalTo(self);
//        make.height.mas_equalTo(0.5);
//    }];
}

- (void)tapAction
{
    ZFWebViewViewController *webVC = [[ZFWebViewViewController alloc] init];
    webVC.link_url = self.model.tracking_url;
    [[UIViewController currentTopViewController].navigationController pushViewController:webVC animated:YES];
}

#pragma mark - Setter
- (void)setModel:(ZFTrackingPackageModel *)model {
    _model = model;
    if (!ZFIsEmptyString(_model.shipping_company)) {
        NSString *title = ZFLocalizedString(@"ZFTracking_Delivery", nil);
        self.shipNameLabel.text = [NSString stringWithFormat:@"%@: %@", title, _model.shipping_company];
    }
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@",ZFLocalizedString(@"ZFTracking_number", nil),ZFToString(model.shipping_no)]];
    NSRange range = [attriString.string rangeOfString:ZFToString(model.shipping_no)];
    [attriString yy_setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : ZFC0x2D2D2D()}];
    [attriString yy_setAttribute:NSForegroundColorAttributeName value:ColorHex_Alpha(0x0099FF, 1.0) range:range];
    self.trackingNumLabel.attributedText = attriString;
}

#pragma mark - Getter
- (UILabel *)shipNameLabel {
    if (!_shipNameLabel) {
        _shipNameLabel = [[UILabel alloc] init];
        _shipNameLabel.font = [UIFont systemFontOfSize:14];
        _shipNameLabel.textColor = ZFC0x2D2D2D();
    }
    return _shipNameLabel;
}

- (UILabel *)trackingNumLabel {
    if (!_trackingNumLabel) {
        _trackingNumLabel = [[UILabel alloc] init];
        _trackingNumLabel.textAlignment = NSTextAlignmentNatural;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        _trackingNumLabel.userInteractionEnabled = YES;
        [_trackingNumLabel addGestureRecognizer:tap];
    }
    return _trackingNumLabel;
}

//- (UIView *)line {
//    if (!_line) {
//        _line = [[UIView alloc] init];
//        _line.backgroundColor = ZFCOLOR(221, 221, 221, 1);
//    }
//    return _line;
//}


@end
