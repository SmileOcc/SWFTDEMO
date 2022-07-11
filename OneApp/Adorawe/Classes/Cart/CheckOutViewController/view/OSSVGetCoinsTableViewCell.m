//
//  OSSVGetCoinsTableViewCell.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVGetCoinsTableViewCell.h"
#import "OSSVCheckOutVC.h"
#import "Adorawe-Swift.h"

@interface OSSVGetCoinsTableViewCell ()
@property (nonatomic, strong) UIView  *grayView;
@property (nonatomic, strong) UILabel *desLabel; //订单金额5%作为金币
@end

@implementation OSSVGetCoinsTableViewCell
@synthesize delegate = _delegate;
@synthesize model = _model;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).priorityHigh();
        }];
        
        [contentView addSubview:self.grayView];
        [self.grayView addSubview:self.desLabel];
              
        [self.grayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentView);
            make.leading.equalTo(14);
            make.trailing.equalTo(-14);
            make.bottom.mas_equalTo(contentView);
        }];
        
        UIImageView *coinImg = [[UIImageView alloc] init];
        coinImg.image = [UIImage imageNamed:@"check_coin"];
        [self.grayView addSubview:coinImg];
        [coinImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(12);
            make.leading.equalTo(6);
            make.centerY.mas_equalTo(self.grayView.mas_centerY);
        }];
        
        
        [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(coinImg.mas_trailing).offset(2);
            make.trailing.equalTo(self.grayView.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.grayView.mas_top).offset(6);
            make.bottom.mas_equalTo(self.grayView.mas_bottom).offset(-6);
            make.height.greaterThanOrEqualTo(12);
        }];
        
        [self addBottomLine:CellSeparatorStyle_LeftRightInset];

        @weakify(self)
        [self.desLabel addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self)
            [self tipAction];
        }];
    }
    return self;
}

- (UIView *)grayView {
    if (!_grayView) {
        _grayView = [UIView new];
        _grayView.backgroundColor = OSSVThemesColors.col_FFF3E4;
    }
    return _grayView;
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [UILabel new];
        _desLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _desLabel.font = [UIFont systemFontOfSize:10];
        _desLabel.numberOfLines = 0;
    }
    return _desLabel;
}



- (void)setModel:(STLGetCoinsTableViewCellModel *)model {
    _model = model;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAttributedString *attrStr=  [[NSAttributedString alloc] initWithData:[model.titleContent dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
        NSMutableAttributedString * mutableAttrStr = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
        [mutableAttrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attrStr.string.length)];

        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        para.alignment = OSSVSystemsConfigsUtils.isRightToLeftShow ? NSTextAlignmentRight : NSTextAlignmentLeft;
        [mutableAttrStr addAttribute:NSParagraphStyleAttributeName value:para range:NSMakeRange(0, attrStr.string.length)];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.desLabel.attributedText = mutableAttrStr;
        });
    });
    self.desLabel.text = [model.titleContent strippedHtml];
}


- (void)tipAction {
    if (_delegate && [_delegate respondsToSelector:@selector(coinInstructionPopView)]) {
        [_delegate coinInstructionPopView];
    }
}
@end


@implementation STLGetCoinsTableViewCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.titleContent = STLLocalizedString_(@"ddddddd", nil);
    }
    return self;
}

+(instancetype)initWithTitile:(NSString *)title
{
    STLGetCoinsTableViewCellModel *model = [[STLGetCoinsTableViewCellModel alloc] init];
    model.titleContent = title;
    return model;
}

@end
