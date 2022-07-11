//
//  YXNewsRecommendCell.m
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/6/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXNewsRecommendCell.h"
#import "YXListNewsModel.h"
#import "YXNewsJumpTagView.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXNewsRecommendCell ()
@property (nonatomic, strong) UIImageView *singleImageView;
@property (nonatomic, strong) UILabel *titleLab; //标题
@property (nonatomic, strong) UILabel *labelLab; //标签
@property (nonatomic, strong) UILabel *sourceLab; //来源
@property (nonatomic, strong) UILabel *dateLab;  //时间
@property (nonatomic, strong) UILabel *stockLab; //股票
@property (nonatomic, strong) UIButton *stockBtn;

//@property (nonatomic, strong) YXNewsJumpTagView *jumpView;
@end

@implementation YXNewsRecommendCell


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI{
    
 
//    self.jumpView = [[YXNewsJumpTagView alloc] init];
    
    self.backgroundColor = QMUITheme.foregroundColor;
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = QMUITheme.separatorLineColor;
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(8);
        make.right.equalTo(self.contentView).offset(-8);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    [self.contentView addSubview:self.singleImageView];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.labelLab];
    [self.contentView addSubview:self.sourceLab];
    [self.contentView addSubview:self.dateLab];
    [self.contentView addSubview:self.stockLab];
//    [self.contentView addSubview:self.jumpView];
//    [self.contentView addSubview:self.closeBtn];
        
    [self.singleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(18);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(69);
        make.width.mas_equalTo(109);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.top.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.singleImageView.mas_left).offset(-17);
    }];
    
    [self.labelLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.height.mas_equalTo(15);
    }];
    
    [self.sourceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labelLab.mas_right).mas_offset(0);
        make.centerY.equalTo(self.labelLab);
    }];
    
    [self.dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sourceLab.mas_right).mas_offset(8);
        make.centerY.equalTo(self.labelLab);
    }];
    
    [self.stockLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.bottom.equalTo(self.contentView).offset(-12);
        make.height.mas_equalTo(20);
    }];
    
//    self.stockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.stockBtn setTitle:@"" forState:UIControlStateNormal];
//    [self.stockBtn addTarget:self action:@selector(stockLabTapAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.contentView addSubview:self.stockBtn];
//    [self.stockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.bottom.equalTo(self.stockLab);
//    }];
//
//    [self.jumpView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.stockLab.mas_right).offset(4);
//        make.right.equalTo(self.contentView).offset(-5);
//        make.height.mas_equalTo(20);
//        make.centerY.equalTo(self.stockLab);
//    }];
    
//    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//
//        make.right.equalTo(self.contentView).offset(-3);
//        make.bottom.equalTo(self.contentView).offset(-5);
//        make.width.mas_equalTo(40);
//        make.height.mas_equalTo(30);
//    }];
    
//    @weakify(self);
//    [self.jumpView setTagJumpCallBack:^(YXListNewsJumpTagModel * _Nonnull tagModel) {
//        @strongify(self);
//        if (self.tagClickCallBack) {
//            self.tagClickCallBack(tagModel);
//        }
//    }];
}

- (void)setModel:(YXListNewsModel *)model {
    _model = model;
    
    if (model.imageUrlArr.count > 0) {
        self.singleImageView.hidden = false;
        [self.titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.top.equalTo(self.contentView).offset(16);
            make.right.equalTo(self.singleImageView.mas_left).offset(-17);
        }];
    } else {
        self.singleImageView.hidden = true;
        [self.titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.top.equalTo(self.contentView).offset(16);
            make.right.equalTo(self.contentView).offset(-16);
        }];
    }
    
    self.titleLab.attributedText = [YXToolUtility attributedStringWithText:[NSString stringWithFormat:@"%@", model.title] font:self.titleLab.font textColor:self.titleLab.textColor lineSpacing:3];
    self.titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
    if (model.isRead) {
        self.titleLab.textColor = [QMUITheme.textColorLevel1 colorWithAlphaComponent:0.4];
    }else{
        self.titleLab.textColor = QMUITheme.textColorLevel1;
    }
    
    self.sourceLab.text = [YXToolUtility maxCharacterWithString:model.source maxCount:30];
    
    NSMutableString *strM = [[NSMutableString alloc] init];
    if (model.date > 0) {
        [strM appendString:@" · "];
        [strM appendString:[YXToolUtility dateStringWithTimeIntervalSince1970:model.date]];
        
    }

    for (YXListNewsJumpTagModel *jumpModel in model.jump_tags) {
        if (jumpModel.jump_type == 0) {
            [strM appendString:@" · "];
            [strM appendString:jumpModel.content];
        }
    }

    self.dateLab.text = strM;
    
//    self.jumpView.list = model.jump_tags;
    
    if ([model.source isNotEmpty]) {
        [self.dateLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.sourceLab.mas_right).mas_offset(0);
        }];
    }else {
        [self.dateLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.sourceLab.mas_right).mas_offset(0);
        }];
    }
    
    CGSize size = CGSizeMake(self.singleImageView.bounds.size.width * [UIScreen mainScreen].scale, self.singleImageView.bounds.size.height * [UIScreen mainScreen].scale);
    id<SDImageTransformer> transformer = [SDImageResizingTransformer transformerWithSize:size scaleMode:SDImageScaleModeAspectFill];
    [self.singleImageView sd_setImageWithURL:[NSURL URLWithString:model.imageUrlArr.firstObject] placeholderImage:[UIImage imageNamed:@"placeholderImage"] options:0 context:@{SDWebImageContextImageTransformer:transformer}];
    
    
    if (model.lable.length > 0) {
        self.labelLab.text = [NSString stringWithFormat:@" %@ ", [YXToolUtility maxCharacterWithString:model.lable maxCount:16]];
        self.labelLab.hidden = NO;
        [self.labelLab sizeToFit];
        [self.sourceLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.labelLab.mas_right).mas_offset(8);
        }];
        
    }else{
        self.labelLab.text = @"";
        [self.labelLab sizeToFit];
        self.labelLab.hidden = YES;
        [self.sourceLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.labelLab.mas_right).mas_offset(0);
        }];
    }
    
    if (model.stockArr.count > 0) {
        
        YXListNewsStockModel *stockModel = model.stockArr.firstObject;
        double gainsNum = stockModel.roc/100.0;
        NSString *stock = [YXToolUtility maxCharacterWithString:stockModel.name maxCount:20];
        NSString *gains = nil;
         if (gainsNum > 0) {
            self.stockLab.backgroundColor = [[QMUITheme stockRedColor] colorWithAlphaComponent:0.05];
            self.stockLab.textColor = QMUITheme.stockRedColor;
             gains = [NSString stringWithFormat:@"+%.2lf%%",gainsNum];
        }else if (gainsNum < 0){
            self.stockLab.backgroundColor = [[QMUITheme stockGreenColor] colorWithAlphaComponent:0.05];
            self.stockLab.textColor = QMUITheme.stockGreenColor;
            gains = [NSString stringWithFormat:@"%.2lf%%",gainsNum];
        }else{
            self.stockLab.backgroundColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.05];
            self.stockLab.textColor = [QMUITheme stockGrayColor];
            gains = [NSString stringWithFormat:@"%.2lf%%",gainsNum];
        }
        NSMutableAttributedString *attrStr = [YXToolUtility attributedStringWithText:[NSString stringWithFormat:@" %@ %@ ", stock, gains] font:self.stockLab.font textColor:self.stockLab.textColor lineSpacing:0];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DINPro-Regular" size:14.0] range:NSMakeRange(attrStr.length-gains.length-1, gains.length)];
        
        self.stockLab.attributedText = attrStr;
        self.stockBtn.hidden = NO;
        self.stockLab.hidden = NO;
        self.titleLab.numberOfLines = 3;
        
//        [self.jumpView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.stockLab.mas_right).offset(4);
//            make.right.equalTo(self.contentView).offset(-5);
//            make.height.mas_equalTo(20);
//            make.centerY.equalTo(self.stockLab);
//        }];
    } else {
        self.stockBtn.hidden = YES;
        self.stockLab.hidden = YES;
        self.stockLab.text = @"";
        self.titleLab.numberOfLines = 3;
        
//        [self.jumpView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.stockLab);
//            make.right.equalTo(self.contentView).offset(-5);
//            make.height.mas_equalTo(20);
//            make.centerY.equalTo(self.stockLab);
//        }];
    }
    
//    self.closeBtn.hidden = model.isHideFeedback;
}

#pragma mark- 懒加载
- (UIImageView *)singleImageView{
    
    if (!_singleImageView) {
        _singleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 109, 69)];
        _singleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _singleImageView.clipsToBounds = YES;
        _singleImageView.layer.cornerRadius = 4;
    }
    return _singleImageView;
}

- (UILabel *)titleLab{
    
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _titleLab.numberOfLines = 3;
        _titleLab.textColor = QMUITheme.textColorLevel1;
    }
    return _titleLab;
}

- (UILabel *)labelLab{
   
    if (!_labelLab) {
        _labelLab = [[UILabel alloc] init];
        _labelLab.font = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
        _labelLab.textColor = QMUITheme.textColorLevel4;
        _labelLab.layer.cornerRadius = 1;
        _labelLab.layer.borderWidth = 0.5;
        _labelLab.layer.borderColor = QMUITheme.textColorLevel4.CGColor;
    }
    return _labelLab;
}

- (UILabel *)sourceLab{
    if (!_sourceLab) {
        _sourceLab = [[UILabel alloc] init];
        _sourceLab.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _sourceLab.textColor = [UIColor qmui_colorWithHexString:@"#AAAAB4"];
    }
    return _sourceLab;
}

- (UILabel *)dateLab{
    if (!_dateLab) {
        _dateLab = [[UILabel alloc] init];
        _dateLab.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _dateLab.textColor = [UIColor qmui_colorWithHexString:@"#AAAAB4"];
    }
    return _dateLab;
}

//- (UILabel *)stockLab{
//    if (!_stockLab) {
//        _stockLab = [[UILabel alloc] init];
//        _stockLab.font = [UIFont normalFont12];
//        _stockLab.layer.cornerRadius = 1;
//        _stockLab.userInteractionEnabled = YES;
//    }
//    return _stockLab;
//}

//- (UIButton *)closeBtn{
//
//    if (!_closeBtn) {
//        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom image:nil target:self action:nil];
//        [_closeBtn setImage:[UIImage imageNamed:@"news_closed"] forState:UIControlStateNormal];
//        _closeBtn.titleLabel.font = [UIFont normalFont12];
//        [_closeBtn setTitleColor:[UIColor colorWithHexString:@"#E1E1E1"] forState:UIControlStateNormal];
//        _closeBtn.hidden = YES;
//    }
//
//    return _closeBtn;
//}

#pragma mark- other
- (void)stockLabTapAction {
    if (self.stockClickCallBack) {
        self.stockClickCallBack();
    }
}


@end
