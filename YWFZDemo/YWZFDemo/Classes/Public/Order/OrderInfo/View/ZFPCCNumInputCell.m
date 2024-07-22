//
//  ZFPCCNumInputCell.m
//  ZZZZZ
//
//  Created by YW on 2019/8/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFPCCNumInputCell.h"
#import "ZFFrameDefiner.h"
#import "ZFLocalizationString.h"
#import "CustomTextField.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "YWCFunctionTool.h"
#import "YYText.h"
#import "NSString+Extended.h"

#import <Masonry/Masonry.h>
@interface ZFPCCNumInputCell ()
<
    UITextFieldDelegate
>
@property (nonatomic, strong) UILabel *pccTipsLabel;
@property (nonatomic, strong) UILabel *pccTipsTitleLabel;
@property (nonatomic, strong) CustomTextField *pccInputTF;
@property (nonatomic, strong) UILabel *failTipsLabel;

@property (nonatomic, copy) NSString *pccNum;

@property (nonatomic, strong) ZFTaxVerifyModel *verifyModel;

@end

@implementation ZFPCCNumInputCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.pccTipsLabel];
        [self addSubview:self.pccTipsTitleLabel];
        [self addSubview:self.pccInputTF];
        [self addSubview:self.failTipsLabel];
        
        CGFloat padding12 = 12;
        CGFloat padding16 = 16;
        CGFloat padding8 = 8;
        [self.pccTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).mas_offset(padding12);
            make.leading.mas_equalTo(self).mas_offset(padding16);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-padding16);
        }];
        self.pccTipsLabel.preferredMaxLayoutWidth = KScreenWidth - 32;
        
        [self.pccTipsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.pccTipsLabel);
            make.top.mas_equalTo(self.pccTipsLabel.mas_bottom).mas_offset(padding8);
            make.trailing.mas_equalTo(self.pccTipsLabel);
        }];
        
        [self.pccInputTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.pccTipsTitleLabel.mas_bottom).mas_offset(3);
            make.leading.mas_equalTo(self).mas_offset(23);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-23);
            make.height.mas_offset(40);
        }];
        
        [self.failTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.pccInputTF.mas_bottom).mas_offset(5);
            make.leading.mas_equalTo(self.pccInputTF);
            make.trailing.mas_equalTo(self.pccInputTF);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-(padding16 - 4));
            make.height.mas_lessThanOrEqualTo(0);
        }];
    }
    return self;
}

+ (NSString *)queryReuseIdentifier
{
    return NSStringFromClass(self.class);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFPCCNumInputCellDidEndEditPccNum:cell:)]) {
        [self.delegate ZFPCCNumInputCellDidEndEditPccNum:textField.text cell:self];
    }
}

#pragma mark - Property Method

- (void)configurate:(ZFTaxVerifyModel *)verifyModel pccNum:(NSString *)pccNum {
    self.verifyModel = verifyModel;
    self.pccNum = pccNum;
    
    [self pccNoteContent];
    [self pccNameContent];
    
}

- (void)setPccNum:(NSString *)pccNum
{
    _pccNum = pccNum;
    if (![_pccNum isEqualToString:ZFShowError]) {
        self.pccInputTF.text = pccNum;
    } else {
        self.pccInputTF.text = @"";
    }
    
    BOOL result = [NSStringUtils matchNewPCCNum:self.pccInputTF.text regex:self.verifyModel.reg];

    if (!result && _pccNum.length) {
        [self showErrorTips];
    } else {
        self.failTipsLabel.hidden = YES;
        [self.failTipsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_lessThanOrEqualTo(0);
        }];
    }
}

- (void)showErrorTips
{
    if (!ZFIsEmptyString(self.verifyModel.error_msg)) {
        self.failTipsLabel.text = self.verifyModel.error_msg;
    }
    self.failTipsLabel.hidden = NO;
    [self.failTipsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_lessThanOrEqualTo(50);
    }];
}

- (void)pccNoteContent {
    NSAttributedString *htmlAttr = self.verifyModel.namehtmlAttr;
    if (!htmlAttr) {
        CGSize size = CGSizeMake(KScreenWidth - 32, CGFLOAT_MAX);
        UIFont *font = [UIFont systemFontOfSize:14];
        [ZFToString(self.verifyModel.pcc_name) calculateHTMLText:size labelFont:font
                                                   lineSpace:nil
                                                   alignment:NSTextAlignmentLeft
                                                  completion:^(NSAttributedString *stringAttributed, CGSize calculateSize) {

            self.verifyModel.namehtmlAttr = stringAttributed;
            self.pccTipsTitleLabel.attributedText = stringAttributed;

            [self.pccTipsTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.pccTipsLabel);
                make.top.mas_equalTo(self.pccTipsLabel.mas_bottom).mas_offset(8);
                make.trailing.mas_equalTo(self.pccTipsLabel);
                make.height.mas_equalTo(calculateSize.height);
            }];
            if (self.refreshCellTextHeight) {
                self.refreshCellTextHeight();
            }
        }];
    } else {
        self.pccTipsTitleLabel.attributedText = htmlAttr;
    }
}

- (void)pccNameContent {
    NSAttributedString *htmlAttr = self.verifyModel.notehtmlAttr;
    if (!htmlAttr) {
        CGSize size = CGSizeMake(KScreenWidth - 32, CGFLOAT_MAX);
        UIFont *font = [UIFont systemFontOfSize:13];
        [ZFToString(self.verifyModel.note) calculateHTMLText:size labelFont:font
                                                   lineSpace:nil
                                                   alignment:NSTextAlignmentLeft
                                                  completion:^(NSAttributedString *stringAttributed, CGSize calculateSize) {
            
            self.verifyModel.notehtmlAttr = stringAttributed;
            self.pccTipsLabel.attributedText = stringAttributed;
            
            [self.pccTipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self).mas_offset(12);
                make.leading.mas_equalTo(self).mas_offset(16);
                make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
                make.height.mas_equalTo(calculateSize.height);
            }];
            if (self.refreshCellTextHeight) {
                self.refreshCellTextHeight();
            }
        }];
    } else {
        self.pccTipsLabel.attributedText = htmlAttr;
    }
}

- (NSMutableAttributedString *)pccNoteString:(NSString *)note {
    
    NSMutableAttributedString *attri;
    if (!ZFIsEmptyString(note)) {
        attri = [[NSMutableAttributedString alloc] initWithString:note];
        
        attri.yy_font = [UIFont systemFontOfSize:13];
        attri.yy_color = ZFC0x666666();

        // 后台返回的是中文（，坑
        NSArray <NSValue *> *rangeValues = [NSStringUtils matchString:note reg:@"\\（(.*?)\\）" matchOptions:NSMatchingReportProgress];

        if (ZFJudgeNSArray(rangeValues) && rangeValues.count == 0) {
            rangeValues = [NSStringUtils matchString:note reg:@"\\((.*?)\\)" matchOptions:NSMatchingReportProgress];
        }
        
        [rangeValues enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [obj rangeValue];
            [attri yy_setColor:ZFC0xFFA800() range:range];
        }];
        
    } else {
        
        NSString *yydd = @"(YYYYMMDD. E.g. 19950512)";
        NSString *text = ZFLocalizedString(@"OrderInfo_PCCTips", nil);
        attri = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range = [text rangeOfString:yydd];
        [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0x666666()} range:NSMakeRange(0, text.length)];
        [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0xFFA800()} range:range];
    }
    return attri;
}

- (NSMutableAttributedString *)pccNameString:(NSString *)name {
    
    NSMutableAttributedString *attri;
    if (!ZFIsEmptyString(name)) {
        
        NSString *text = [NSString stringWithFormat:@"%@",name];
        attri = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range = [text rangeOfString:@"*"];
        [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0x2D2D2D()} range:NSMakeRange(0, text.length)];
        [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0xFFA800()} range:range];
        
    } else {
        
        NSString *text = [NSString stringWithFormat:@"*%@", ZFLocalizedString(@"OrderInfo_PCCNumTitle", nil)];
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range = [text rangeOfString:@"*"];
        [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0x2D2D2D()} range:NSMakeRange(0, text.length)];
        [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0xFFA800()} range:range];
    }
    return attri;
}


-(UILabel *)pccTipsLabel
{
    if (!_pccTipsLabel) {
        _pccTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            NSString *yydd = @"(YYYYMMDD. E.g. 19950512)";
            NSString *text = ZFLocalizedString(@"OrderInfo_PCCTips", nil);
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:text];
            NSRange range = [text rangeOfString:yydd];
            [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0x666666()} range:NSMakeRange(0, text.length)];
            [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0xFFA800()} range:range];
            label.attributedText = attri;
//            label.textColor = ZFC0x666666();
            label.font = [UIFont systemFontOfSize:13];
            label;
        });
    }
    return _pccTipsLabel;
}

-(UILabel *)pccTipsTitleLabel
{
    if (!_pccTipsTitleLabel) {
        _pccTipsTitleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            NSString *text = [NSString stringWithFormat:@"*%@", ZFLocalizedString(@"OrderInfo_PCCNumTitle", nil)];
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:text];
            NSRange range = [text rangeOfString:@"*"];
            [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0x2D2D2D()} range:NSMakeRange(0, text.length)];
            [attri addAttributes:@{NSForegroundColorAttributeName : ZFC0xFFA800()} range:range];
            label.attributedText = attri;
//            label.textColor = [UIColor blackColor];
            label.font = [UIFont boldSystemFontOfSize:14];
            label;
        });
    }
    return _pccTipsTitleLabel;
}

- (CustomTextField *)pccInputTF
{
    if (!_pccInputTF) {
        _pccInputTF = ({
            CustomTextField *textField = [[CustomTextField alloc] init];
            textField.font = [UIFont systemFontOfSize:14];
            textField.placeholderPadding = 12;
            textField.layer.borderWidth = .5;
            textField.layer.cornerRadius = 3;
            textField.layer.masksToBounds = YES;
            textField.layer.borderColor = ColorHex_Alpha(0xDCDCDC, 1.0).CGColor;
            textField.delegate = self;
            textField;
        });
    }
    return _pccInputTF;
}

-(UILabel *)failTipsLabel
{
    if (!_failTipsLabel) {
        _failTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.hidden = YES;
            label.text = ZFLocalizedString(@"OrderInfo_PCCErrorTips", nil);
            label.textColor = ColorHex_Alpha(0xFF0000, 1.0);
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _failTipsLabel;
}

@end
