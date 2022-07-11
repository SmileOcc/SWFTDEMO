//
//  YXStockListCell.m
//  YouXinZhengQuan
//
//  Created by ellison on 2018/12/17.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXStockListCell.h"
#import "YXMobileBrief1Label.h"
#import <Masonry/Masonry.h>

#import "uSmartOversea-Swift.h"

@interface YXStockListCell ()



@end

@implementation YXStockListCell
@dynamic model;

- (void)initialUI {
    [super initialUI];
    
    [self.contentView addSubview:self.scrollView];
    [self.contentView addGestureRecognizer:self.scrollView.panGestureRecognizer];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(160);
        } else {
            make.left.mas_equalTo(160);
        }
        make.top.bottom.right.equalTo(self);
    }];
}

- (void)resetScrollViewLeftOffset:(CGFloat)offset {
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(offset);
        } else {
            make.left.mas_equalTo(offset);
        }
        make.top.bottom.right.equalTo(self);
    }];
}

- (void)refreshUI {
    [super refreshUI];
    self.delayLabel.hidden = (self.model.level == 0) ? NO : YES;
    [self.labels enumerateObjectsUsingBlock:^(YXMobileBrief1Label * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.mobileBrief1Object = self.model;
    }];
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.userInteractionEnabled = NO;
    }
    return _scrollView;
}

- (NSArray<YXMobileBrief1Label *> *)labels {
    if (_labels == nil) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        [self.sortTypes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YXMobileBrief1Label *label = [YXMobileBrief1Label labelWithMobileBrief1Type:[obj intValue]];
            [arr addObject:label];
        }];
        
        _labels = [arr copy];
    }
    return _labels;
}

- (void)setSortTypes:(NSArray *)sortTypes {
    _sortTypes = sortTypes;
    
    [self.labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _labels = nil;
    
    
    __block CGFloat width = 0;
    [self.labels enumerateObjectsUsingBlock:^(YXMobileBrief1Label * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(width, 0, 90, self.frame.size.height);
        if (obj.mobileBrief1Type == YXMobileBrief1TypeVolume || obj.mobileBrief1Type == YXMobileBrief1TypeYXScore) {
            obj.frame = CGRectMake(width, 0, 100, self.frame.size.height);
            width += (100 + 20);
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypeAccer5 || obj.mobileBrief1Type == YXMobileBrief1TypePctChg5day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg10day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg30day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg60day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg120day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg250day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg1year || obj.mobileBrief1Type == YXMobileBrief1TypeAvgSpread || obj.mobileBrief1Type == YXMobileBrief1TypeOpenOnTime || obj.mobileBrief1Type == YXMobileBrief1TypeOneTickSpreadProducts || obj.mobileBrief1Type == YXMobileBrief1TypeOneTickSpreadDuration || obj.mobileBrief1Type == YXMobileBrief1TypeYXSelection) {
            if (YXUserManager.curLanguage == YXLanguageTypeEN || YXUserManager.curLanguage == YXLanguageTypeTH) {
                obj.frame = CGRectMake(width, 0, 130, self.frame.size.height);
                width += (130 + 20);
            } else {
                obj.frame = CGRectMake(width, 0, 110, self.frame.size.height);
                width += (110 + 20);
            }
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypePreAndClosePrice || obj.mobileBrief1Type == YXMobileBrief1TypeAfterAndClosePrice || obj.mobileBrief1Type == YXMobileBrief1TypePreRoc || obj.mobileBrief1Type == YXMobileBrief1TypeAfterRoc) {
            CGFloat w = (UIScreen.mainScreen.bounds.size.width-175)/2.0;
            obj.frame = CGRectMake(width, 0, w, self.frame.size.height);
            width += w;
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypeWarrantBuy) {
            if (YXUserManager.curLanguage == YXLanguageTypeTH) {
                obj.frame = CGRectMake(width, 0, 160, self.frame.size.height);
                width += (160 + 20);
            } else {
                width += (90 + 20);
            }
        } else {
            width += (90 + 20);
        }
        [self.scrollView addSubview:obj];
    }];
    
    self.scrollView.contentSize = CGSizeMake(width + 5, self.frame.size.height);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
