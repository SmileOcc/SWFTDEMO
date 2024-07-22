//
//  ZFCommunityMenuView.m
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityMenuView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommunityMenuView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray  <ZFMenuItem *>        *menuDatas;
@property (nonatomic, strong) UITableView                    *menuTable;
@property (nonatomic, strong) UIControl                      *bgTapControl;


@end

@implementation ZFCommunityMenuView

- (instancetype)initWithFrame:(CGRect)frame menus:(NSArray<ZFMenuItem *> *) menus{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.menuDatas = menus;
        
        [self addSubview:self.bgTapControl];
        [self addSubview:self.menuTable];
        
        [self.menuTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(8);
            make.top.mas_equalTo(self.mas_top);
            make.width.mas_equalTo(160);
            make.height.mas_equalTo(self.menuDatas.count * 44);
        }];
        
        [self.bgTapControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}



#pragma mark - action

- (void)actionBgTap{
    [self hideView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideView];
    if (self.menuDatas.count > indexPath.row) {
        ZFMenuItem *itemModel = self.menuDatas[indexPath.row];
        if (self.menuSelectBlock) {
            self.menuSelectBlock(itemModel);
        }
    }
}

- (void)showView:(UIView *)superView startPoint:(CGPoint)point {
    if (!superView) {
        return;
    }
    if (!self.superview) {
        [superView addSubview:self];
    }
    
    if (!CGPointEqualToPoint(point, CGPointZero)) {
        [self.menuTable mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(point.x);
            make.top.mas_equalTo(self.mas_top).mas_offset(point.y);
        }];
    }
    
    if (self.hidden == YES) {
        self.hidden = NO;
        CGFloat duration = 0.3;
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = @[@(0.7), @(1), @(1.05), @(1)];
        animation.keyTimes = @[@(0), @(0.3), @(0.5), @(1.0)];
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        animation.duration = duration;
        [self.menuTable.layer addAnimation:animation forKey:@"bouce"];
        
    } else {
        [self hideView];
    }
}
- (void)hideView {
    self.hidden = YES;
    if (self.superview) {
        [self removeFromSuperview];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityMenuTableCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFCommunityMenuTableCell class]) forIndexPath:indexPath];
    if (self.menuDatas.count > indexPath.row) {
        ZFMenuItem *itemModel = self.menuDatas[indexPath.row];
        cell.imgView.image = itemModel.img;
        cell.titleLab.text = ZFToString(itemModel.name);
    }
    return cell;
}


- (UITableView *)menuTable {
    if (!_menuTable) {
        _menuTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _menuTable.backgroundColor = ZFCOLOR_WHITE;
        _menuTable.accessibilityElementsHidden = 48;
        _menuTable.delegate = self;
        _menuTable.dataSource = self;
        _menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_menuTable registerClass:[ZFCommunityMenuTableCell class] forCellReuseIdentifier:NSStringFromClass([ZFCommunityMenuTableCell class])];
        
        _menuTable.layer.shadowColor = ZFCOLOR(51, 51, 51, .5).CGColor;//阴影颜色
        _menuTable.layer.shadowOpacity = 0.3;//不透明度
        _menuTable.layer.shadowRadius = 3.0;//半径
        _menuTable.layer.shadowOffset = CGSizeMake(0, 0);//偏移距离
        _menuTable.layer.masksToBounds = NO; //裁剪
        //self.bgView.layer.shouldRasterize = YES;//设置缓存 仅复用时设置此选项
        _menuTable.layer.rasterizationScale = KScale;//设置对应比例，防止cell出现模糊和锯齿
    }
    return _menuTable;
}

- (UIControl *)bgTapControl {
    if (!_bgTapControl) {
        _bgTapControl = [[UIControl alloc] initWithFrame:CGRectZero];
        [_bgTapControl addTarget:self action:@selector(actionBgTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgTapControl;
}
@end



@implementation ZFCommunityMenuTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.imgView];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.lineView];

        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(22, 22));
        }];

        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.imgView.mas_trailing).offset(16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.centerY.mas_equalTo(self.imgView.mas_centerY);
        }];

        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.imgView.mas_leading).offset(16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imgView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLab.textColor = ColorHex_Alpha(0x030303, 1.0);
        _titleLab.font = ZFFontSystemSize(14);
        _titleLab.numberOfLines = 2;
    }
    return _titleLab;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ColorHex_Alpha(0xDDDDDD, 0.2);
    }
    return _lineView;
}
@end



@implementation ZFMenuItem

@end
