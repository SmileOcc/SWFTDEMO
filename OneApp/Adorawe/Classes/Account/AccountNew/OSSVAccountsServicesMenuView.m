//
//  OSSVAccountsServicesMenuView.m
//  Adorawe
//
//  Created by odd on 2021/10/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVAccountsServicesMenuView.h"
#import "OSSVAccountsItemsView.h"

@implementation OSSVAccountsServicesMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        
        [self addSubview:self.headerView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.lineView];
        [self addSubview:self.contentView];
        
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(self);
            make.height.mas_equalTo(40);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.headerView.mas_leading).offset(14);
            make.top.mas_equalTo(self.headerView.mas_top).offset(14);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.headerView.mas_leading).offset(14);
            make.trailing.mas_equalTo(self.headerView.mas_trailing).offset(-14);
            make.bottom.mas_equalTo(self.headerView.mas_bottom);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.headerView.mas_bottom).offset(5);
            make.height.mas_equalTo(134);
        }];
        
        self.layer.masksToBounds = YES;
        
        OSSVAccountsItemsView *tempView = nil;
        CGFloat itemW = SCREEN_WIDTH / 4.0;
       
        for (int i=0; i< 8; i++) {
            OSSVAccountsMenuItemsModel *itemModel = nil;
            OSSVAccountsItemsView *itemView = [[OSSVAccountsItemsView alloc] initWithFrame:CGRectZero image:itemModel.itemImage title:itemModel.itemTitle];
            itemView.tag = 4000+i;
            [itemView addTarget:self action:@selector(actionOrder:) forControlEvents:UIControlEventTouchUpInside];

            [self.contentView addSubview:itemView];
            
            int row = i % 4;
            int col = i / 4;
            if (tempView) {
                if (row == 0 && col == 1) {
                    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.mas_equalTo(self.contentView);
                        make.top.mas_equalTo(self.contentView.mas_top).offset(58+6);
                        make.height.mas_equalTo(58);
                        make.width.mas_equalTo(itemW);
                    }];
                    
                } else {
                    
                    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.mas_equalTo(tempView.mas_trailing);
                        make.top.mas_equalTo(tempView.mas_top);
                        make.width.mas_equalTo(tempView.mas_width);
                        make.height.mas_equalTo(tempView.mas_height);
                    }];
                }
            } else {
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.top.mas_equalTo(self.contentView);
                    make.height.mas_equalTo(58);
                    make.width.mas_equalTo(itemW);
                }];
            }
            tempView = itemView;
        }
    }
    return self;
}

+ (CGFloat)contentHeight {
    CGFloat heigth = 40 + 58 + 6 + 5;
//    if (USERID) {
//        heigth += 58 + 6;
//    }
    return heigth;
}

- (void)actionOrder:(UIButton *)button {
    if (self.didSelectBlock) {
        NSInteger tag = button.tag - 4000;
        if (self.datas.count > tag) {
            
            OSSVAccountsMenuItemsModel *model = self.datas[tag];
            self.didSelectBlock(tag, model);
        }
    }
}

- (void)updateDatas:(NSArray<OSSVAccountsMenuItemsModel*> *)datas {
    if (STLJudgeNSArray(datas)) {
        self.datas = datas;
    }
    
    for (int i=0; i< 8; i++) {
        OSSVAccountsItemsView *itemView = [self.contentView viewWithTag:4000+i];
        itemView.hidden = YES;
        OSSVAccountsMenuItemsModel *itemModel = nil;
        if (i < self.datas.count) {
            itemModel = self.datas[i];
            itemView.hidden = NO;
        }
        [itemView image:itemModel.itemImage title:itemModel.itemTitle];
    }
}

- (NSArray *)datas {
    if (!_datas) {
        _datas = @[];
    }
    return _datas;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectZero];
        _headerView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _headerView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
        _lineView.hidden = YES;
    }
    return _lineView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = STLLocalizedString_(@"More_services", nil);
        if (APP_TYPE == 3) {
            _titleLabel.font = [UIFont vivaiaRegularFont:16];
        } else {
            _titleLabel.font = [UIFont systemFontOfSize:14];
        }
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _titleLabel;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _contentView;
}
@end
