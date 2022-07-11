//
//  GBSettingCell.m
//  GearBest
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "GBSettingCell.h"
#import "GBSettingSwitchItem.h"
#import "GBSettingArrowItem.h"
#import "GBSettingLabelItem.h"
#import "GBSettingImageItem.h"
#import "JSBadgeView.h"

@interface GBSettingCell ()
/** 箭头 */
@property (nonatomic, strong) YYAnimatedImageView *arrowView;
/** 开关 */
@property (nonatomic, strong) UISwitch *switchView;
/** 标签 */
@property (nonatomic, strong) UILabel *labelView;
/** 头像 */
@property (nonatomic, strong) YYAnimatedImageView *headView;
/** 指示器 */
@property (nonatomic, strong) UIView *badgeView;

@property (nonatomic, weak) UIView *divider;

@property (nonatomic, assign) BOOL registerObserver;

@end


@implementation GBSettingCell
- (YYAnimatedImageView *)arrowView
{
    if (_arrowView == nil) {
        _arrowView = [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
    }
    return _arrowView;
}

- (UISwitch *)switchView
{
    if (_switchView == nil) {
        _switchView = [[UISwitch alloc] init];
        [_switchView addTarget:self action:@selector(switchStateChange) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (YYAnimatedImageView *)headView
{
    if (_headView == nil) {
        _headView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
//        [_headView sd_setImageWithURL:[NSURL URLWithString:self.item.headImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            _headView.image = image;
//        }];
        [_headView yy_setImageWithURL:[NSURL URLWithString:self.item.headImage]
                          placeholder:[UIImage imageNamed:@"headerImage"]
                              options:YYWebImageOptionShowNetworkActivity
                           completion:nil];
        
        [self.item addObserver:self forKeyPath:@"headImage" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        
        _headView.layer.cornerRadius = 25;
        _headView.clipsToBounds = YES;
//        _headView.layer.borderWidth = 5;
//        _headView.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:159/255.0 blue:118/255.0 alpha:0.2] CGColor];
//        _headView.backgroundColor = [UIColor colorWithRed:202/255.0 green:159/255.0 blue:118/255.0 alpha:0.2];
        _headView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headView;
}

- (UIView *)badgeView {
    if (!_badgeView) {
        _badgeView = [[UIView alloc] init];
        _badgeView.backgroundColor = [OSSVThemesColors col_FF4E6A];
        _badgeView.frame = CGRectMake(0, 0, 16, 16);
        _badgeView.layer.cornerRadius = 8;
        _badgeView.clipsToBounds = YES;
        [self.accessoryView addSubview:_badgeView];
    }
    return _badgeView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 初始化操作
        
        // 1.初始化背景
        [self setupBg];
        
        // 2.初始化子控件
        [self setupSubviews];
        
        // 3.初始化分割线
        
        [self setupDivider];
        
    }
    return self;
}

/**
 *  初始化子控件
 */
- (void)setupSubviews
{
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
}

/**
 *  初始化背景
 */
- (void)setupBg
{
    // 设置普通背景
    UIView *bg = [[UIView alloc] init];
    bg.backgroundColor = [UIColor whiteColor];
    self.backgroundView = bg;
    
    // 设置选中时的背景
    UIView *selectedBg = [[UIView alloc] init];
    //    selectedBg.backgroundColor = MJColor(237, 233, 218);
    self.selectedBackgroundView = selectedBg;
}

/**
 *  初始化分割线
 */
- (void)setupDivider
{
    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = [UIColor blackColor];
    divider.alpha = 0.2;
    [self.contentView addSubview:divider];
    self.divider = divider;
}

/**
 *  监听开关状态改变
 */
- (void)switchStateChange
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    if (self.item.key) {
    [defaults setBool:self.switchView.isOn forKey:self.item.title];
    [defaults synchronize];
    //    }
}

- (UILabel *)labelView
{
    if (_labelView == nil)
    {
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow])
        {
            _labelView.textAlignment = NSTextAlignmentLeft;
        }
        else
        {
            _labelView.textAlignment = NSTextAlignmentRight;
        }
        _labelView.textColor = self.item.contentColor? self.item.contentColor : OSSVThemesColors.col_999999;
        _labelView.font = [UIFont systemFontOfSize:14];
        _labelView.text = self.item.content;
        
        CGSize size =[_labelView.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        _labelView.bounds = CGRectMake(0, 0, size.width, 30);
        
        [self.item addObserver:self forKeyPath:@"content" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        self.registerObserver = YES;
    }
    return _labelView;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"content"])
    {
        _labelView.text = [self.item valueForKey:@"content"];
        CGSize titleSize = [self.item.content sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        //此处是为了输入时或选中时重新设置label的frame
        CGRect rect = _labelView.frame;
        rect.origin.x = titleSize.width + 85;
        rect.size.width = SCREEN_WIDTH - rect.origin.x - 15;
        _labelView.frame = rect;
   
    } else if([keyPath isEqualToString:@"headImage"]) {
//        [_headView sd_setImageWithURL:[NSURL URLWithString:[self.item valueForKey:@"headImage"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            _headView.image = image;
//        }];
        _headView.image = [UIImage imageWithContentsOfFile:[self.item valueForKey:@"headImage"]];
    }
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"setting";
    GBSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[GBSettingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    return cell;
}

/**
 *  拦截frame的设置
 */
- (void)setFrame:(CGRect)frame
{
    //    if (!iOS7) {
    //        CGFloat padding = 10;
    //        frame.size.width += padding * 2;
    //        frame.origin.x = -padding;
    //    }
    [super setFrame:frame];
}

/**
 *  设置子控件的frame
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 改变Label 的高度为了让其居中
    CGRect rect = self.textLabel.frame;
    rect.origin = CGPointMake(rect.origin.x, 0);
    rect.size = CGSizeMake(rect.size.width, self.contentView.frame.size.height);
    self.textLabel.frame = rect;

    CGRect arrRect = self.accessoryView.frame;
    arrRect.origin = CGPointMake(arrRect.origin.x, (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(arrRect)) / 2.0);
    self.accessoryView.frame = arrRect;
    
    
    // 设置分割线的frame
//    CGFloat dividerH = 1;
//    CGFloat dividerW = [UIScreen mainScreen].bounds.size.width;
//    CGFloat dividerX = 0;
//    CGFloat dividerY = self.contentView.frame.size.height - dividerH;
//    self.divider.frame = CGRectMake(dividerX, dividerY, dividerW, dividerH);
}

- (void)setItem:(GBSettingItem *)item
{
    _item = item;
    
    // 1.设置数据
    [self setupData];
    
    // 2.设置右边的内容
    [self setupRightContent];
}

- (void)setLastRowInSection:(BOOL)lastRowInSection
{
    _lastRowInSection = lastRowInSection;
    
    self.divider.hidden = lastRowInSection;
}

/**
 *  设置右边的内容
 */
- (void)setupRightContent
{
    if ([self.item isKindOfClass:[GBSettingArrowItem class]]) { // 箭头
        self.accessoryView = self.arrowView;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
        }
        if (self.item.badgeBlock) {
            if (self.item.badgeBlock() > 0) {
                self.badgeView.hidden = NO;
            } else {
                self.badgeView.hidden = YES;
            }
        }
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if ([self.item isKindOfClass:[GBSettingSwitchItem class]]) { // 开关
        self.accessoryView = self.switchView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 设置开关的状态
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.switchView.on = [defaults boolForKey:self.item.title];
    } else if ([self.item isKindOfClass:[GBSettingLabelItem class]]) { // 标签
        self.accessoryView = self.labelView;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if ([self.item isKindOfClass:[GBSettingImageItem class]]) {
        self.accessoryView = self.headView;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        self.accessoryView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
}

/**
 *  设置数据
 */
- (void)setupData
{
    if (self.item.icon) {
        self.imageView.image = [UIImage imageNamed:self.item.icon];
    }
    
    self.textLabel.font = [UIFont systemFontOfSize:14];
    [self.textLabel setTextColor:OSSVThemesColors.col_333333];
    
    self.textLabel.numberOfLines = 2;
    
    
    if (self.item.subtitle) {
        NSString *str = [NSString stringWithFormat:@"%@\n%@",self.item.title,self.item.subtitle];
        NSMutableAttributedString *strArr = [[NSMutableAttributedString alloc] initWithString:str];
        NSRange strRange = [str rangeOfString:self.item.subtitle];
        [strArr addAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize: 11],
                                           NSForegroundColorAttributeName: OSSVThemesColors.col_999999 } range:strRange];
        self.textLabel.attributedText = strArr;
    } else {
        if ([self.item.title isKindOfClass:[NSAttributedString class]]) {
            self.textLabel.attributedText = (NSAttributedString *)self.item.title;
        } else {
            self.textLabel.text = self.item.title;
        }
    }
    
//    self.detailTextLabel.text = self.item.subtitle;
}

- (void)dealloc {
    if (self.registerObserver) {
        [self.item removeObserver:self forKeyPath:@"content"];
    }
//    @try {
//         [self.item removeObserver:self forKeyPath:@"content"];
//        //    [self.item removeObserver:self forKeyPath:@"icon"];
//    }
//    @catch (NSException *exception) {
//        
//    }
   

}
@end
