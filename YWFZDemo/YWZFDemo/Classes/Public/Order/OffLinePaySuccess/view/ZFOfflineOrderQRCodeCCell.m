//
//  ZFOfflineOrderQRCodeCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOfflineOrderQRCodeCCell.h"
#import "ZFLocalizationString.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "UIImage+ZFExtended.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFOrderPayTools.h"
#import "ExchangeManager.h"
#import "YWCFunctionTool.h"
#import "ZFProgressHUD.h"
#import <Masonry/Masonry.h>

#pragma mark - subview

@interface ZFOfflineOrderQRCodeText : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation ZFOfflineOrderQRCodeText

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.contentLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).mas_offset(16);
            make.leading.trailing.mas_equalTo(self);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(6);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-17);
            make.leading.trailing.mas_equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Property Method

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = @"";
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _titleLabel;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont boldSystemFontOfSize:26];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _contentLabel;
}

@end

@interface ZFOfflineOrderQRCodeCCell ()

@property (nonatomic, strong) UIView *backBorderView;
@property (nonatomic, strong) ZFOfflineOrderQRCodeText *moneyLabel;
@property (nonatomic, strong) ZFOfflineOrderQRCodeText *dateLabel;
@property (nonatomic, strong) UIImageView *qrCodeImage;
@property (nonatomic, strong) UILabel *qrCodeLabel;
@property (nonatomic, strong) UIButton *qrCopyButton;

@property (nonatomic, strong) UILabel *payCodeTipsLabel;

@end

@implementation ZFOfflineOrderQRCodeCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backBorderView];
        [self.backBorderView addSubview:self.moneyLabel];
        [self.backBorderView addSubview:self.dateLabel];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(KScreenWidth);
        }];
        
        [self.backBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(16, 16, 16, 16));
        }];
        
        [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backBorderView);
            make.leading.mas_equalTo(self.backBorderView);
            make.width.mas_equalTo(self.backBorderView).multipliedBy(0.5);
        }];
        
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backBorderView);
            make.trailing.mas_equalTo(self.backBorderView);
            make.width.mas_equalTo(self.moneyLabel);
        }];
        
        UIView *verticalLine = [[UIView alloc] init];
        verticalLine.backgroundColor = ZFC0xDDDDDD();
        [self.backBorderView addSubview:verticalLine];
        
        [verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backBorderView);
            make.bottom.mas_equalTo(self.moneyLabel.mas_bottom);
            make.centerX.mas_equalTo(self.backBorderView.mas_centerX);
            make.width.mas_offset(1);
        }];
        
        [self.backBorderView addSubview:self.qrCodeImage];
        [self.backBorderView addSubview:self.qrCodeLabel];
        [self.backBorderView addSubview:self.qrCopyButton];
        [self.backBorderView addSubview:self.payCodeTipsLabel];
        
        [self.qrCodeImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.moneyLabel.mas_bottom).mas_offset(15);
            make.leading.mas_equalTo(self.backBorderView).mas_offset(12);
            make.trailing.mas_equalTo(self.backBorderView.mas_trailing).mas_offset(-12);
            make.height.mas_offset(40);
        }];
        
        [self.qrCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.qrCodeImage.mas_bottom).mas_offset(12);
            make.leading.mas_equalTo(self.qrCodeImage);
            make.trailing.mas_equalTo(self.qrCopyButton.mas_leading).mas_offset(-10);
            make.bottom.mas_equalTo(self.backBorderView.mas_bottom).mas_offset(-16);
        }];
        
        [self.qrCopyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.qrCodeLabel);
            make.trailing.mas_equalTo(self.qrCodeImage);
            make.leading.mas_equalTo(self.qrCodeLabel.mas_trailing).mas_offset(10);
            make.size.mas_offset(CGSizeMake(24, 24));
        }];
        
        [self.payCodeTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.moneyLabel.mas_bottom).mas_offset(15);
            make.leading.mas_equalTo(self.backBorderView).mas_offset(12);
            make.trailing.mas_equalTo(self.backBorderView.mas_trailing).mas_offset(-12);
            make.height.mas_offset(16);
        }];
        
        UIView *horLine = [[UIView alloc] init];
        horLine.backgroundColor = verticalLine.backgroundColor;
        [self.backBorderView addSubview:horLine];
        
        [horLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.backBorderView);
            make.top.mas_equalTo(verticalLine.mas_bottom);
            make.height.mas_offset(1);
        }];
    }
    return self;
}

#pragma mark - target

- (void)copyButtonClick
{
    UIPasteboard *pasteBorard = [UIPasteboard generalPasteboard];
    pasteBorard.string = ZFToString(self.model.boletoBarcode);
    ShowToastToViewWithText(self.superview, ZFLocalizedString(@"Share_VC_Copied_Success", nil));
}

#pragma mark - Property Method

- (void)setModel:(ZFOrderPayResultModel *)model
{
    _model = model;
    
    if ([model isBoletoPayment] || [model isOXXOPayment]) {
        //botelo支付方式布局
        //生成条形码
        NSString *barcode = @"";
        NSString *barcodeText = @"";
        if ([model isBoletoPayment]) {
            barcode = model.boletoBarcodeRaw;
            barcodeText = model.boletoBarcode;
        } else if ([model isOXXOPayment]) {
            barcode = model.ebanxBarcode;
            barcodeText = model.ebanxBarcode;
        }
        if (!self.qrCodeImage.image) {
            UIImage *barCode = [UIImage barcodeImageWithContent:barcode codeImageSize:CGSizeMake(KScreenWidth - 56, 40) red:0 green:0 blue:0];
            self.qrCodeImage.image = barCode;
        }

        self.moneyLabel.contentLabel.text = [ExchangeManager transAppendPrice:model.payCurrencyAmount currency:model.currencySign];
        self.qrCodeLabel.text = barcodeText;
        self.dateLabel.contentLabel.text = model.dueDate;

        self.payCodeTipsLabel.hidden = YES;
        [self.payCodeTipsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
    }
    
    if ([model isPagoefePayment]) {
        //pagoefe支付方式布局
        self.qrCodeImage.hidden = YES;
        [self.qrCodeImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
        [self.qrCodeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.payCodeTipsLabel.mas_bottom).mas_offset(12);
            make.leading.mas_equalTo(self.qrCodeImage);
            make.trailing.mas_equalTo(self.qrCopyButton.mas_leading).mas_offset(-10);
            make.bottom.mas_equalTo(self.backBorderView.mas_bottom).mas_offset(-16);
        }];
        self.moneyLabel.contentLabel.text = [ExchangeManager transAppendPrice:model.payCurrencyAmount currency:model.currencySign];
        self.qrCodeLabel.text = model.boletoBarcode;
        self.qrCodeLabel.font = [UIFont systemFontOfSize:26];
        self.dateLabel.contentLabel.text = model.dueDate;
    }
}

- (UIView *)backBorderView
{
    if (!_backBorderView) {
        _backBorderView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.borderWidth = 1;
            view.layer.borderColor = ZFC0xDDDDDD().CGColor;
            view;
        });
    }
    return _backBorderView;
}

- (ZFOfflineOrderQRCodeText *)moneyLabel
{
    if (!_moneyLabel) {
        _moneyLabel = [[ZFOfflineOrderQRCodeText alloc] init];
        _moneyLabel.titleLabel.text = ZFLocalizedString(@"PayOffline_Transactionamount", nil);
    }
    return _moneyLabel;
}

- (ZFOfflineOrderQRCodeText *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[ZFOfflineOrderQRCodeText alloc] init];
        _dateLabel.titleLabel.text = ZFLocalizedString(@"PayOffline_DueDate", nil);
    }
    return _dateLabel;
}

- (UIImageView *)qrCodeImage
{
    if (!_qrCodeImage) {
        _qrCodeImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img;
        });
    }
    return _qrCodeImage;
}

-(UILabel *)qrCodeLabel
{
    if (!_qrCodeLabel) {
        _qrCodeLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.textColor = ZFC0x2D2D2D();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _qrCodeLabel;
}

- (UIButton *)qrCopyButton {
    if (!_qrCopyButton) {
        _qrCopyButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"orderCopy"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(copyButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [button setEnlargeEdge:20];
            button;
        });
    }
    return _qrCopyButton;
}

-(UILabel *)payCodeTipsLabel
{
    if (!_payCodeTipsLabel) {
        _payCodeTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
            label.text = ZFLocalizedString(@"OrderInfo_PagoPayCIPCode", nil);
            label.textColor = ZFC0x666666();
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _payCodeTipsLabel;
}

@end
