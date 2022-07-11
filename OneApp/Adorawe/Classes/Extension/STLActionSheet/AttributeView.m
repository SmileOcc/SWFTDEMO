//
//  AttributeView.m
// XStarlinkProject
//
//  Created by 10010 on 2017/9/18.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "AttributeView.h"

@interface AttributeView ()



@end

@implementation AttributeView

+ (AttributeView *)attributeViewWithCollectionView:(UICollectionView *)collectionView kind:(NSString*)kind indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[AttributeView class] forSupplementaryViewOfKind:kind withReuseIdentifier:@"AttributeView"];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"AttributeView" forIndexPath:indexPath];
}

- (void)setKeyword:(NSString *)keyword {
    _keyword = keyword;
    //判断字符串中是否包含： ----这里区分两个字符串的字体不同
//    if (keyword && [keyword containsString:@":"]) {
//        //以字符:中分隔成2个元素的数组
//        NSArray *array = [keyword componentsSeparatedByString:@":"];
//        NSLog(@"拆分的字符串： %@", array);
//        NSString *firstStr = [NSString stringWithFormat:@"%@:", array[0]];
//        NSString *secondStr = (NSString *)array[1];
//        //所有单词首字母转化大写
//        NSString *totalStr = [[NSString stringWithFormat:@"%@%@", firstStr, secondStr] capitalizedStringWithLocale:[NSLocale currentLocale]];
//        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:totalStr];
//        [attStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, firstStr.length)];
//        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(firstStr.length, secondStr.length)];
//        self.titleLabel.attributedText = attStr;
//    }
//    _titleLabel.text = [keyword capitalizedStringWithLocale:[NSLocale currentLocale]];
    _titleLabel.text = [NSString stringWithFormat:@"%@:", keyword];
}

- (void)setDetailWords:(NSString *)detailWords{
    _detailWords = detailWords;
    _detLabel.text = [NSString stringWithFormat:@"%@", STLToString(detailWords)];
}

// 根据sizechar && sizeChartUrl 存在显示跳转按钮
- (void)setSizeChart:(NSString *)sizeChart {
    _sizeChart = sizeChart;
    self.rulerLabel.text = sizeChart;
}

- (void)setSizeChartUrl:(NSString *)sizeChartUrl {
    _sizeChartUrl = sizeChartUrl;
}

- (void)setHideEvent:(BOOL)hideEvent {
    _hideEvent = hideEvent;
    self.eventBtn.hidden = hideEvent;
    self.rulerImgView.hidden = hideEvent;
    self.arrowImgView.hidden = hideEvent;
    self.rulerLabel.hidden = hideEvent;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.topLineView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.detLabel];
 
        [self addSubview:self.rulerImgView];
        [self addSubview:self.rulerLabel];
        [self addSubview:self.arrowImgView];
        [self addSubview:self.eventBtn];
        
        [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.centerY.mas_equalTo(self).mas_offset(5);
            make.height.mas_equalTo(self);
        }];
        
        [self.detLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_trailing);
            make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
            make.height.mas_equalTo(self);
        }];
        
        [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];

        [self.rulerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.arrowImgView.mas_leading);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];

        [self.rulerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.rulerLabel.mas_leading).mas_offset(-3);
            make.centerY.mas_equalTo(self.arrowImgView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(16, 16));
        }];
        
        
        
        [self.eventBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing);
            make.top.bottom.mas_equalTo(self);
            make.leading.mas_equalTo(self.rulerLabel.mas_leading);
        }];
        
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _titleLabel.text = nil;
    _rulerLabel.text = nil;
}

#pragma mark - setter / getter

- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _topLineView.backgroundColor = OSSVThemesColors.col_EFEFEF;
        _topLineView.hidden = YES;
    }
    return _topLineView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _titleLabel;
}

- (UILabel *)detLabel{
    if (!_detLabel) {
        _detLabel = [[UILabel alloc] init];
        _detLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _detLabel.font = [UIFont systemFontOfSize:14];
    }
    return _detLabel;
}

- (UILabel *)rulerLabel {
    if (!_rulerLabel) {
        _rulerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rulerLabel.textColor = [OSSVThemesColors col_666666];
        _rulerLabel.font = [UIFont systemFontOfSize:11];
        _rulerLabel.text = STLLocalizedString_(@"Size_chart", nil);
//        _rulerLabel.hidden = YES;
    }
    return _rulerLabel;
}

- (UIButton *)eventBtn {
    if (!_eventBtn) {
        _eventBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eventBtn addTarget:self action:@selector(eventBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
//        _eventBtn.hidden = YES;
    }
    return _eventBtn;
}

- (UIImageView *)rulerImgView {
    if (!_rulerImgView) {
        _rulerImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_size"]];
//        _rulerImgView.hidden = YES;
    }
    return _rulerImgView;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = [UIImage imageNamed:@"detail_right_arrow"];
        _arrowImgView.hidden = YES;
        [_arrowImgView convertUIWithARLanguage];
    }
    return _arrowImgView;
}

#pragma mark
#pragma mark - Click on the event

- (void)eventBtnTouch:(UIButton*)sender {
    if (self.eventBlock && self.sizeChartUrl) {
        self.eventBlock(self.sizeChartUrl);
    }
}

@end
