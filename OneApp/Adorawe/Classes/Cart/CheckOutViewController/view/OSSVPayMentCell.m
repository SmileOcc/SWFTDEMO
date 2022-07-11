//
//  OSSVPayMentCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVPayMentCell.h"

#define TopPadding 5

@interface OSSVPayMentCell ()
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *selectImage;
@property (nonatomic,weak) UIStackView *containerView;
@property (nonatomic, strong) UILabel *payMentLabel;
@property (nonatomic, strong) UILabel *discountLabel; //折扣
@property (nonatomic, assign) BOOL    isChangeSelectImage;   //定义改变选中图标的变量
@property (nonatomic, strong) UILabel *codServicePrice; //COD服务费减免

@property (nonatomic,weak) UILabel *extraDdescLbl;
@end

@implementation OSSVPayMentCell
@synthesize delegate = _delegate;
@synthesize model = _model;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_changePaymentSelectedRedIcon object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_changePaymentSelectedIcon object:nil];

}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _isChangeSelectImage = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSelectImage) name:kNotif_changePaymentSelectedRedIcon object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSelectIcon) name:kNotif_changePaymentSelectedIcon object:nil];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.cellBgView];
        [self.cellBgView addSubview:self.iconImageView];
        [self.cellBgView addSubview:self.selectImage];
        
        UIStackView *container = [[UIStackView alloc] init];
        [self.cellBgView addSubview:container];
        self.containerView = container;
        container.axis = UILayoutConstraintAxisVertical;
        container.distribution = UIStackViewDistributionFillEqually;
        container.alignment = UIStackViewAlignmentLeading;
        
        [self.containerView addArrangedSubview:self.payMentLabel];
        [self.containerView addArrangedSubview:self.codServicePrice];
        [self.cellBgView addSubview:self.discountLabel];
    
        UIView *contentView = self.contentView;
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).priorityHigh();
        }];
        
        [self.cellBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentView);
            make.bottom.mas_equalTo(contentView.mas_bottom).offset(-6);
            make.leading.mas_equalTo(contentView.mas_leading).offset(14);
            make.trailing.mas_equalTo(contentView.mas_trailing).offset(-14);
        }];
        
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.leading.mas_equalTo(self.cellBgView.mas_leading).mas_offset(CheckOutCellLeftPadding);
            } else {
                make.leading.mas_equalTo(self.cellBgView.mas_leading).mas_offset(0);
            }
            make.width.mas_offset(26);
            make.height.mas_offset(18);
            make.top.equalTo(16);
        }];
        [self.selectImage mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.trailing.mas_equalTo(self.cellBgView.mas_trailing).mas_offset(-CheckOutCellLeftPadding);
            } else {
                make.trailing.mas_equalTo(self.cellBgView.mas_trailing).mas_offset(0);
            }
            make.size.mas_equalTo(CGSizeMake(18, 18));
            make.top.equalTo(16);
        }];
        
        [container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.iconImageView.mas_trailing).mas_offset(8);
            make.trailing.mas_equalTo(self.selectImage.mas_leading).offset(-10);
            make.top.equalTo(self.contentView.mas_top).offset(8);
            make.height.greaterThanOrEqualTo(36);
        }];
        
        
        [self.discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.payMentLabel.mas_trailing).offset(4);
            make.centerY.mas_equalTo(self.payMentLabel);
            make.height.equalTo(17);
            make.width.equalTo(0);
        }];
        
        UILabel *extraDesc = [[UILabel alloc] init];
        extraDesc.backgroundColor = OSSVThemesColors.col_FAFAFA;
        [self.contentView addSubview:extraDesc];
        self.extraDdescLbl = extraDesc;
        
        [extraDesc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(14);
            make.trailing.equalTo(-14);
            make.top.mas_equalTo(container.mas_bottom).offset(0);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-8);
            make.height.equalTo(0);
        }];
        if (APP_TYPE != 3) {
            [self addBottomLine:CellSeparatorStyle_LeftRightInset];
        }
        [self addContentViewTap:@selector(didClickContent)];
    }
    return self;
}

-(void)didClickContent {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_PayMentCellDidClick:)]) {
        [self.delegate STL_PayMentCellDidClick:self.model];
    }
}

-(void)setModel:(OSSVPayMentCellModel *)model {
    _model = model;
    
    [self isHiddenBottomLine:model.islast];
    
    if (!model.showDetail) {
        self.userInteractionEnabled = YES;
    } else {
       
        self.userInteractionEnabled = NO;

    }
    
    self.payMentLabel.attributedText = model.paymentTitle;
    self.iconImageView.image = model.paymentIcon;
    
    //展示支付折扣信息
    NSString *payDiscountStr = STLToString(model.payMentModel.payDiscount);
    NSString *upToDiscount = model.payMentModel.payment_discount_desc;
    
    if (upToDiscount.length > 0) {
        self.discountLabel.text = [NSString stringWithFormat:@"%@",STLToString(upToDiscount)];
        self.discountLabel.hidden = NO;
        
        CGFloat width = [self.discountLabel sizeThatFits:CGSizeMake(MAXFLOAT, 17)].width + 8;
        [self.discountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(width);
        }];
    }else if (payDiscountStr.length && payDiscountStr.intValue > 0) {
        self.discountLabel.hidden = NO;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            self.discountLabel.text = [NSString stringWithFormat:@"%@ %@%@", STLLocalizedString_(@"off", nil),payDiscountStr,@"%"];
        } else {
            self.discountLabel.text = [NSString stringWithFormat:@"%@%@ %@", payDiscountStr,@"%",STLLocalizedString_(@"off", nil)];
        }
        
        CGFloat width = [self.discountLabel sizeThatFits:CGSizeMake(MAXFLOAT, 17)].width + 8;
        [self.discountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(width);
        }];
    }else{
        self.discountLabel.hidden = NO;
    }
    
    if (self.isChangeSelectImage && !model.showDetail) { //没选中支付方式，并且是可选的支付方式
           
        [self.selectImage setImage:[UIImage imageNamed:@"payUnSelect_red"]];

    } else {
        if (model.isSelect) { //如果有选中的
            [self.selectImage setImage:[UIImage imageNamed:@"pay_Selected"]];
            if (APP_TYPE == 3) {
                self.cellBgView.layer.borderColor = OSSVThemesColors.col_0D0D0D.CGColor;
            }

        }else{
            if (model.showDetail) { //如果有不可用的
                [self.selectImage setImage:[UIImage imageNamed:@"pay_Disable"]];
                UIImage *grayImage =  [self changeGrayImage:self.iconImageView.image];
                self.iconImageView.image = grayImage;
                if (APP_TYPE == 3) {
                    self.cellBgView.layer.borderColor = OSSVThemesColors.stlClearColor.CGColor;
                }

            } else {
                [self.selectImage setImage:[UIImage imageNamed:@"pay_UnSelect"]];
                if (APP_TYPE == 3) {
                    self.cellBgView.layer.borderColor = OSSVThemesColors.stlClearColor.CGColor;
                }

            }
        }
    }
    
    //COD服务费赋值
    NSString *codStr = STLToString(model.checkModel.cod_discount_info.codTextStr);
    NSString *redPrice = STLToString(model.checkModel.cod_discount_info.codRedPrice);
    NSString *codDisPrice = STLToString(model.checkModel.cod_discount_info.codDiscount);
    NSString *totalStr = @"";
    totalStr = [NSString stringWithFormat:@"%@%@ %@", codStr, redPrice, codDisPrice];

    if (redPrice.length) {
        totalStr = [NSString stringWithFormat:@"%@ %@ %@", codStr, codDisPrice, redPrice];

    } else {
        totalStr = [NSString stringWithFormat:@"%@ %@", codStr, codDisPrice];

    }
    
    self.codServicePrice.hidden = YES;
    if ([model.payMentModel isCodPayment]) {
        self.codServicePrice.hidden = NO;
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:totalStr];
        if (redPrice.length) {
            
            [attStr addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_999999 range:NSMakeRange(0, codStr.length + codDisPrice.length)];
            [attStr addAttribute:NSForegroundColorAttributeName value:APP_TYPE == 3 ? OSSVThemesColors.col_9F5123 : OSSVThemesColors.col_B62B21   range:NSMakeRange(codStr.length + codDisPrice.length+2,redPrice.length)];
            
            [attStr addAttributes:@{NSForegroundColorAttributeName:OSSVThemesColors.col_999999,
                                    NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],
                                    NSFontAttributeName:[UIFont systemFontOfSize:11],
                                    NSBaselineOffsetAttributeName:@(NSUnderlineStyleSingle)
            } range:NSMakeRange(codStr.length+ 1, codDisPrice.length)];

            [attStr addAttribute:NSBaselineOffsetAttributeName value:@(0.36 * (11 - 11)) range:NSMakeRange(codStr.length+1, codDisPrice.length)];
            self.codServicePrice.attributedText = attStr;
        } else {
            if (model.paymentDetail.length) {
                self.codServicePrice.text = model.paymentDetail;
                self.codServicePrice.textColor = OSSVThemesColors.col_B2B2B2;
            }else{
                self.codServicePrice.attributedText = attStr;
            }
           
        }
        
    }
    self.codServicePrice.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    if (model.payMentModel.dialog_tip_text.length > 0) {
        self.codServicePrice.hidden = NO;
        self.codServicePrice.text = model.payMentModel.dialog_tip_text;
        self.codServicePrice.textColor = OSSVThemesColors.col_999999;
    }
    
        //KOL支付方式
    if ([model.payMentModel isInfluencerPayment] && model.payMentModel.payVoucherDiscountDesc.length) {
        self.codServicePrice.hidden = NO;
        

        
        @weakify(self)
        //网红单剩余次数 1.4.4 单独放一行
        if (!STLIsEmptyString(model.payMentModel.payVoucherNumberDesc)) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSAttributedString *attrStr=  [[NSAttributedString alloc] initWithData:[model.payMentModel.payVoucherNumberDesc dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
                NSMutableAttributedString * mutableAttrStr = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
                NSAttributedString *attr = [[NSAttributedString alloc] initWithString:@"  "];
                [mutableAttrStr insertAttributedString:attr atIndex:0];
                [mutableAttrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, attrStr.string.length)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self)
                    self.extraDdescLbl.attributedText = mutableAttrStr;
                });
            });
            
            [self.extraDdescLbl mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.containerView.mas_bottom).offset(9.5);
                make.height.equalTo(28);
            }];
        }
        //网红单支付方式描述
        self.codServicePrice.text = [NSString stringWithFormat:@"%@%@", STLToString(model.payMentModel.payVoucherDiscountDesc),STLToString(model.payMentModel.payVoucherDiscountAmount)];

        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            self.codServicePrice.textAlignment = NSTextAlignmentRight;
        } else {
            self.codServicePrice.textAlignment = NSTextAlignmentLeft;
        }
    }else{
        [self.extraDdescLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView.mas_bottom).offset(0);
            make.height.equalTo(0);
        }];
    }
            
}

#pragma mark -- 通知处理
- (void)changeSelectImage {
    self.isChangeSelectImage = YES;
}
- (void)changeSelectIcon {
    self.isChangeSelectImage = NO;

}
#pragma mark - setter and getter

-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView;
        });
    }
    return _iconImageView;
}

-(UIImageView *)selectImage
{
    if (!_selectImage) {
        _selectImage = [UIImageView new];
        _selectImage.image = [UIImage imageNamed:@"pay_UnSelect"];
    }
    return _selectImage;
}

-(UILabel *)payMentLabel
{
    if (!_payMentLabel) {
        _payMentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = @"";
            label.textColor = OSSVThemesColors.col_0D0D0D;
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _payMentLabel;
}

- (UILabel *)discountLabel {
    if (!_discountLabel) {
        _discountLabel = [UILabel new];
        _discountLabel.textAlignment = NSTextAlignmentCenter;
        if (APP_TYPE == 3) {
            _discountLabel.textColor = OSSVThemesColors.col_9F5123;
            _discountLabel.backgroundColor = OSSVThemesColors.stlWhiteColor;
            _discountLabel.layer.borderColor = OSSVThemesColors.col_F5EEE9.CGColor;
            _discountLabel.layer.borderWidth = 1.f;
        } else {
            _discountLabel.textColor = OSSVThemesColors.col_B62B21;
            _discountLabel.backgroundColor = OSSVThemesColors.col_FBE9E9;
        }
        _discountLabel.font = [UIFont boldSystemFontOfSize:10];

        [_discountLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                        forAxis:UILayoutConstraintAxisHorizontal];
        [_discountLabel setContentHuggingPriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _discountLabel;
}

- (UILabel *)codServicePrice {
    if (!_codServicePrice) {
        _codServicePrice = [UILabel new];
        _codServicePrice.numberOfLines = 0;
        _codServicePrice.font = [UIFont systemFontOfSize:11];
        _codServicePrice.textColor = OSSVThemesColors.col_666666;
    }
    return _codServicePrice;
}

- (UIView *)cellBgView {
    if (!_cellBgView) {
        _cellBgView = [[UIView  alloc] init];
        _cellBgView.backgroundColor = OSSVThemesColors.stlWhiteColor;
        if (APP_TYPE == 3) {
            _cellBgView.layer.borderColor = OSSVThemesColors.stlClearColor.CGColor;
            _cellBgView.layer.borderWidth =  1.f;
            _cellBgView.layer.masksToBounds = YES;
        }
    }
    return _cellBgView;
}

    //***********图片置灰操作
-(UIImage *)changeGrayImage:(UIImage *)oldImage{
            CIContext *context = [CIContext contextWithOptions:nil];
            CIImage *superImage = [CIImage imageWithCGImage:oldImage.CGImage];
            CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
            [lighten setValue:superImage forKey:kCIInputImageKey];
     // 修改亮度   -1---1   数越大越亮
            [lighten setValue:@(0) forKey:@"inputBrightness"];
            // 修改饱和度  0---2
            [lighten setValue:@(0) forKey:@"inputSaturation"];
      // 修改对比度  0---4
            [lighten setValue:@(0.5) forKey:@"inputContrast"];
            CIImage *result = [lighten valueForKey:kCIOutputImageKey];
            CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
            // 得到修改后的图片
            UIImage *newImage =  [UIImage imageWithCGImage:cgImage];
            // 释放对象
            CGImageRelease(cgImage);
        return newImage;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.codServicePrice.hidden = true;
}
@end
