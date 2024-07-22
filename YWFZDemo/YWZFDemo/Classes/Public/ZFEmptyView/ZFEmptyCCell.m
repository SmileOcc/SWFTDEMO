//
//  ZFEmptyCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/6/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFEmptyCCell.h"
#import "ZFInitViewProtocol.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "ZFThemeManager.h"

@interface ZFEmptyCCell()<ZFInitViewProtocol>

@end

@implementation ZFEmptyCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    [self.contentView addSubview:self.emptyView];
}

- (void)zfAutoLayoutView {
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
}


- (void)setMsg:(NSString *)msg {
    _msg = msg;
    self.emptyView.msg = _msg;
}

- (void)setMsgImage:(UIImage *)msgImage {
    _msgImage = msgImage;
    self.emptyView.msgImage = _msgImage;
}

- (ZFEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[ZFEmptyView alloc] initWithFrame:CGRectZero];
    }
    return _emptyView;
}
@end
