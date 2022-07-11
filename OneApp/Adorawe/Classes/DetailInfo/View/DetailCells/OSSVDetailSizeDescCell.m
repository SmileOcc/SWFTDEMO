//
//  OSSVDetailSizeDescCell.m
// XStarlinkProject
//
//  Created by odd on 2021/6/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailSizeDescCell.h"
#import "Adorawe-Swift.h"

@interface OSSVDetailSizeDescCell ()<WKScriptMessageHandler>

@end


@implementation OSSVDetailSizeDescCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
//        self.chartView = [self detailViewAction:@selector(tapArrView:)];
        self.descView = [self detailViewAction:@selector(tapDescView:)];
        
//        [self.bgView addSubview:self.chartView];
        [self.bgView addSubview:self.descView];
        [self.bgView addSubview:self.lineView];

        [self.descView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.chartView.mas_bottom);
            make.top.mas_equalTo(self.bgView.mas_top);
            make.leading.trailing.mas_equalTo(self.bgView);
            make.height.mas_offset(kSizeDescHeight);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
            make.centerY.mas_equalTo(self.bgView.mas_centerY);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.bgView addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(0);
            make.height.equalTo(self.bodyH);
        }];
        
        self.descView.rightArrow.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    return self;
}

- (void)updateHeaderGoodsSelect:(OSSVDetailsBaseInfoModel *)goodsInforModel {
    self.model = goodsInforModel;
    self.lineView.hidden = YES;
    NSURL *url = [NSURL URLWithString:goodsInforModel.urlmdesc];
//    NSURL *url = [NSURL URLWithString:@"http://172.28.7.2:8080"];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:req];
    // 描述
    [self.descView setTitle:STLLocalizedString_(@"description",nil) isArrow:YES];
}

#pragma mark 尺寸
- (void)tapArrView:(UITapGestureRecognizer *)sender {

    if (self.model) {
        if (self.stlDelegate && [self.stlDelegate respondsToSelector:@selector(OSSVDetialCell:sizeChat:)]) {
            [self.stlDelegate OSSVDetialCell:self sizeChat:[self.model goodsChartSizeUrl]];
        }
    }
}

#pragma mark 描述
- (void)tapDescView:(UITapGestureRecognizer *)sender {

    [GATools logGoodsDetailSimpleEventWithEventName:@"product_description"
                                            screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.model.goodsTitle)]
                                             buttonName:@"PDR"];

    if (self.stlDelegate && [self.stlDelegate respondsToSelector:@selector(OSSVDetialCell:description:)]) {
        [self.stlDelegate OSSVDetialCell:self description:STLToString(self.model.urlmdesc)];
    }
}

- (OSSVDetailArrView *)detailViewAction:(SEL)action{
    OSSVDetailArrView *arrView = [[OSSVDetailArrView alloc] init];
    if (action) {
        UITapGestureRecognizer *tapArr = [[UITapGestureRecognizer alloc]initWithTarget:self action:action];
        [arrView addGestureRecognizer:tapArr];
    }
    return arrView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
        _lineView.hidden = YES;
    }
    return _lineView;
}

-(WKWebView *)webView{
    if (!_webView) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userCC = [WKUserContentController new];
        [userCC addScriptMessageHandler:self name:@"getWkWebViewHeight"];
        config.userContentController = userCC;
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) configuration:config];
        [_webView injectGetHeight];
        _webView.hidden = true;
        _webView.userInteractionEnabled = false;
    }
    return _webView;
}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if([message.name isEqualToString:@"getWkWebViewHeight"]){
        NSDictionary *data = message.body;
        NSInteger bodyH = [[data objectForKey:@"bodyH"] integerValue];
        self.bodyH = bodyH;
        NSLog(@"getWkWebViewHeight: %@",data);
        [self.webView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.bodyH);
        }];
    }
}
@end
