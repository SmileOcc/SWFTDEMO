//
//  ZFNoDataTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/7/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNoDataTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "Masonry.h"

@interface ZFNoDataTableViewCell () <ZFInitViewProtocol>
/** 空白View */
@property (nonatomic, strong) UIView *view;

@end

@implementation ZFNoDataTableViewCell

+ (NSString *)queryReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView{
    [self.contentView addSubview:self.view];
}

- (void)zfAutoLayoutView{
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsZero);
        make.height.mas_equalTo(0.001);
    }];
}

-(UIView *)view{
    if (!_view) {
        _view = [[UIView alloc] init];
        _view.backgroundColor = [UIColor clearColor];
    }
    return _view;
}

@end
