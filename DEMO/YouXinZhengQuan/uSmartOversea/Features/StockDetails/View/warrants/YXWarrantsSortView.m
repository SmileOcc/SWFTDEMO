//
//  YXWarrantsSortView.m
//  uSmartOversea
//
//  Created by 井超 on 2019/7/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXWarrantsSortView.h"
#import <Masonry/Masonry.h>

@interface YXWarrantsSortView () 

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSArray *titleArr;

@end

@implementation YXWarrantsSortView

- (instancetype)initWithTitleArr:(NSArray *)titleArr selectIndex:(NSInteger)index {
   
    if (self = [super initWithFrame:CGRectZero]) {
        self.index = index;
        self.titleArr = titleArr;
        [self initialization];
    }
    
    return self;
}

- (void)initialization {

    self.backgroundColor = QMUITheme.popupLayerColor;
    for (int i = 0; i<self.titleArr.count; i++) {
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = QMUITheme.popupLayerColor;
        [self addSubview:backView];
        if (i == self.titleArr.count - 1) {
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.width.equalTo(self);
                make.top.equalTo(self).offset(i+i*51+1);
                make.height.mas_equalTo(51);
                make.bottom.equalTo(self);
            }];
        } else {
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.width.equalTo(self);
                make.top.equalTo(self).offset(i+i*51+1);
                make.height.mas_equalTo(51);
            }];
        }
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.text = self.titleArr[i];
        titleLab.font = [UIFont systemFontOfSize:16];
        
        if (i == self.index) {
           
            titleLab.textColor = [QMUITheme mainThemeColor];
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"edit_checked"];
            [backView addSubview:imageView];
            backView.backgroundColor = QMUITheme.blockColor;
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(backView);
                make.right.equalTo(backView).offset(-16);
            }];
            
        }else {
            titleLab.textColor = [QMUITheme textColorLevel1];
        }
        
//        if (i != self.titleArr.count-1) {
//            UIView *line = [[UIView alloc] init];
//            line.backgroundColor = line.backgroundColor = [UIColor qmui_colorWithHexString:@"#E1E1E1"];
//            line.alpha = 0.5;
//            [backView addSubview:line];
//
//            [line mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(backView).offset(8);
//                make.right.equalTo(backView).offset(-8);
//                make.bottom.equalTo(backView);
//                make.height.mas_equalTo(1);
//            }];
//        }
        
        [backView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView).offset(16);
            make.centerY.equalTo(backView);
        }];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 10 + i;
        [btn setTitle:@"" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        [backView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(backView);
        }];
        
    }
}

- (void)btnAction:(UIButton *)btn {
    NSInteger index = btn.tag - 10;
    if (self.seletedBlock) {
        self.seletedBlock(index);
    }
}



@end
