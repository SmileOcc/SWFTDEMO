//
//  OSSVRulesView.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVRulesView.h"
#import "OSSVRulesSubsdCell.h"
#import "UIView+STLCategory.h"
#import <AudioToolbox/AudioToolbox.h>

@interface OSSVRulesView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *ruleScroll;
@property (nonatomic, strong) UIImageView *ruleImgV;

@property (nonatomic, assign) NSInteger minValue;
@property (nonatomic, assign) NSInteger maxValue;

@property (nonatomic, strong) NSMutableArray *showArray;// 要显示的放在数组里面

@property (nonatomic, assign) NSInteger row;//滚动的row 用于声音的控制
@property (nonatomic, assign) NSInteger num;// 记录第一次展示的时候的row（由于float的精度问题）

@end

@implementation OSSVRulesView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.showArray = [NSMutableArray arrayWithCapacity:30];
        [self setUpView];
    }
    return self;
}

- (void)setUpView{
    [self addSubview:self.ruleScroll];
    [self addSubview:self.ruleImgV];
    _ruleScroll.showsVerticalScrollIndicator = NO;
    _ruleScroll.showsHorizontalScrollIndicator = NO;
    
    [self.ruleScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.ruleImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(-2);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.height.mas_equalTo(16);
    }];
}


- (UICollectionView *)ruleScroll{
    if (!_ruleScroll) {
        
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.minimumLineSpacing = 0;
        flow.minimumInteritemSpacing = 0;
        flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _ruleScroll = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
        _ruleScroll.delegate = self;
        _ruleScroll.dataSource = self;
        _ruleScroll.backgroundColor = [UIColor clearColor];
        
        [_ruleScroll registerClass:[OSSVRulesSubsdCell class] forCellWithReuseIdentifier:@"OSSVRulesSubsdCell"];
        
    }
    return _ruleScroll;
}

- (UIImageView *)ruleImgV{
    if (!_ruleImgV) {
        _ruleImgV = [UIImageView new];
        _ruleImgV.image = [UIImage imageNamed:@"size_rule"];
    }
    return _ruleImgV;
}

- (void)setType:(sizeCellType)type{
    _type = type;
    
    if (type == sizeCellTypeHeight) {
        if (_sizeType == 1) {
            self.minValue = 50;
            self.maxValue = 230;
            
            for (NSInteger i = self.minValue; i<self.maxValue + 1; i++) {
                if (i%10 == 0) {
                    [self.showArray addObject:[NSString stringWithFormat:@"%ld", i]];
                }
            }
        }else{
            self.minValue = 19;
            self.maxValue = 90;
            
            for (NSInteger i = self.minValue; i<self.maxValue + 1; i++) {
                [self.showArray addObject:[NSString stringWithFormat:@"%.1lf", (CGFloat)i]];
            }
        }
        
    }else{
        if (_sizeType == 1) {
            self.minValue = 10;
            self.maxValue = 150;
        }else{
            self.minValue = 22;
            self.maxValue = 330;
        }
        
        for (NSInteger i = self.minValue; i<self.maxValue + 1; i++) {
            [self.showArray addObject:[NSString stringWithFormat:@"%.1lf", (CGFloat)i]];
        }
    }
    
    [self.ruleScroll reloadData];
}

- (void)setSizeType:(NSInteger)sizeType{
    _sizeType = sizeType;
}

- (void)setDefaultValue:(double)defaultValue{
    _defaultValue = defaultValue;
    if (_type == sizeCellTypeHeight && _sizeType == 1) {
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            NSInteger num = self.maxValue - _defaultValue;
            self.num = num;
            double itemW = self.frame.size.width / 40;
            [self.ruleScroll setContentOffset:CGPointMake(num*itemW, 0)];
        }else{
            NSInteger num = _defaultValue - self.minValue;
            self.num = num;
            double itemW = self.frame.size.width / 40;
            [self.ruleScroll setContentOffset:CGPointMake(num*itemW, 0)];
        }
    }else{
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            NSInteger num = self.maxValue*10 - _defaultValue * 10;
            double itemW = self.frame.size.width / 40;
            [self.ruleScroll setContentOffset:CGPointMake(num*itemW, 0)];
        }else{
            NSInteger num = _defaultValue * 10 - self.minValue*10;
            double itemW = self.frame.size.width / 40;
            double x = num * itemW;
            [self.ruleScroll setContentOffset:CGPointMake(x, 0)];
        }
        
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger number = self.maxValue - self.minValue;
    if (_type == sizeCellTypeHeight && _sizeType == 1) {
        return number + 40;
    }else{
        return number* 10 + 40;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVRulesSubsdCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OSSVRulesSubsdCell" forIndexPath:indexPath];
    
    NSInteger number = self.maxValue - self.minValue;
    if (_type == sizeCellTypeHeight  && _sizeType == 1) {
        if (indexPath.item < 20 || indexPath.item > number + 20) {
            if (indexPath.item % 10 == 0) {
                [cell showLabWithSure:NO];
            }else{
                [cell hideLab];
            }
            
        }else{
            NSString *tag = [NSString stringWithFormat:@"%ld", indexPath.item - 20 + self.minValue];
            if ([self.showArray containsObject:tag]) {
                [cell showLabWithSure:YES];
                [cell valueLabText:tag];
            }else{
                [cell hideLab];
            }
        }
    }else{
        if (indexPath.item < 20 || indexPath.item > number*10 + 20) {
            if (indexPath.item % 10 == 0) {
                [cell showLabWithSure:NO];
            }else{
                [cell hideLab];
            }
            
        }else{
            NSString *tag = [NSString stringWithFormat:@"%.1lf", 0.1 * (indexPath.item - 20) + self.minValue];
            if ([self.showArray containsObject:tag]) {
                [cell showLabWithSure:YES];
                // 将tag转换成整数
                NSString *newTag = [NSString stringWithFormat:@"%ld", (NSInteger)[tag floatValue]];
                [cell valueLabText:newTag];
            }else{
                [cell hideLab];
            }
        }
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat itemW = self.frame.size.width / 40;
    CGFloat itemH = self.frame.size.height;
    return CGSizeMake(itemW, itemH);
}

// 滚动代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    double itemW = self.frame.size.width / 40;
    double scrollWidth = scrollView.contentOffset.x + 0.1;
    NSString *str = nil;

    NSInteger row = 0;
    if (self.type == sizeCellTypeHeight && _sizeType == 1) {
        row = scrollWidth/itemW;
        if (self.num != 0) {
            row = self.num;
            self.num = 0;
        }
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            str = [NSString stringWithFormat:@"%ld", self.maxValue - row];
        }else{
            str = [NSString stringWithFormat:@"%ld", row + self.minValue];
        }
    }else{
        row = scrollWidth/itemW + 0.1;
        if (self.num != 0) {
            row = self.num;
            self.num = 0;
        }
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            str = [NSString stringWithFormat:@"%.1lf", self.maxValue - row*0.1];
        }else{
            str = [NSString stringWithFormat:@"%.1lf", row*0.1 + self.minValue];
        }
    }
    
    if (self.row != row) {
        self.row = row;
        [self playSound];
    }
    
    if (self.scrollblock) {
        self.scrollblock(str);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self startActionWithScrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startActionWithScrollView:scrollView];
}

- (void)startActionWithScrollView:(UIScrollView *)scrollView{
    CGFloat itemW = self.frame.size.width / 40;
    CGFloat scrollWidth = scrollView.contentOffset.x;
    NSString *str = nil;
    if (self.type == sizeCellTypeHeight  && _sizeType == 1) {
        NSInteger row = scrollWidth/itemW;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [scrollView setContentOffset:CGPointMake(row*itemW, 0)];
            str = [NSString stringWithFormat:@"%ld", self.maxValue - row];
        }else{
            [scrollView setContentOffset:CGPointMake(row*itemW, 0)];
            str = [NSString stringWithFormat:@"%ld", row + self.minValue];
        }
        
    }else{
        NSInteger row = scrollWidth/itemW;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [scrollView setContentOffset:CGPointMake(row*itemW, 0)];
            str = [NSString stringWithFormat:@"%.1lf", self.maxValue - row*0.1];
        }else{
            [scrollView setContentOffset:CGPointMake(row*itemW, 0)];
            str = [NSString stringWithFormat:@"%.1lf", row*0.1 + self.minValue];
        }
        
    }
    
    if (self.scrollblock) {
        self.scrollblock(str);
        [self playSound];
    }
}

- (void)playSound{
    if (@available(iOS 10.0, *)) {
        AudioServicesPlaySystemSoundWithCompletion(1157, nil);
        UIImpactFeedbackGenerator *impactFeedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [impactFeedBack prepare];
        [impactFeedBack impactOccurred];
    }
}

@end
