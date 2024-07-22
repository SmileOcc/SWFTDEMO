//
//  ZFPopCustomerView.m
//  ZZZZZ
//
//  Created by YW on 2019/3/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFPopCustomerView.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFColorDefiner.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import <Masonry/Masonry.h>

@class ZFNewPushAllowCellModel;

#pragma mark - ============= 一些cell =============

#pragma mark - image and content and mark

///带选择对勾的cell
@interface ZFCustomerSelectMarkCell : UITableViewCell
<
    UITableViewCellProtocol
>
@property (nonatomic, strong) UIImageView *selectImage;
@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation ZFCustomerSelectMarkCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.selectImage];
        [self addSubview:self.iconImage];
        [self addSubview:self.contentLabel];
 
        [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(20);
            make.size.mas_offset(CGSizeMake(40, 24));
            make.top.mas_equalTo(self.mas_top).mas_offset(10);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-10);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.iconImage.mas_trailing).mas_offset(12);
            make.trailing.mas_equalTo(self.selectImage.mas_leading).mas_offset(5);
            make.centerY.mas_equalTo(self.iconImage);
        }];
        
        [self.selectImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_offset(CGSizeMake(24, 24));
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-20);
        }];
    }
    return self;
}

#pragma mark - Property Method

-(void)setModel:(id<CustomerViewProtocol>)model
{
    _model = model;
    
    if ([_model isKindOfClass:[CustomerSelectMarkModel class]]) {
        CustomerSelectMarkModel *selectModel = (CustomerSelectMarkModel *)_model;
        NSString *selecImageName = @"";
        if (selectModel.isSelect) {
            selecImageName = @"theme_choose";
        }
        self.selectImage.image = [UIImage imageNamed:selecImageName];

        self.contentLabel.text = selectModel.content;
        
        if (selectModel.image) {
            self.iconImage.image = selectModel.image;
        } else if (selectModel.imagePath) {
            self.iconImage.image = [UIImage imageNamed:selectModel.imagePath];
            if (!self.iconImage.image) {
                [self.iconImage yy_setImageWithURL:[NSURL URLWithString:selectModel.imagePath] options:YYWebImageOptionIgnoreAnimatedImage];
            }
        }
    }
}

- (UIImageView *)selectImage
{
    if (!_selectImage) {
        _selectImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img;
        });
    }
    return _selectImage;
}

- (UIImageView *)iconImage
{
    if (!_iconImage) {
        _iconImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img;
        });
    }
    return _iconImage;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.textColor = ZFC0x2D2D2D();
            label.font = [UIFont systemFontOfSize:16];
            label;
        });
    }
    return _contentLabel;
}

@end

#pragma mark - ZFNewPushAllowImageCell
@interface ZFCustomerImageCell : UITableViewCell
<
    UITableViewCellProtocol
>
@property (nonatomic, strong) YYAnimatedImageView *cellImageView;
@end

@implementation ZFCustomerImageCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.cellImageView];
        
        [self.cellImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.bottom.mas_equalTo(self);
            make.height.mas_equalTo(self.mas_width).multipliedBy(0.44);
        }];
    }
    return self;
}

-(void)setModel:(id<CustomerViewProtocol>)model
{
    _model = model;
    
    if ([_model isKindOfClass:[CustomerImageModel class]]) {
        CustomerImageModel *imageModel = (CustomerImageModel *)_model;
        if (imageModel.image) {
            _cellImageView.image = imageModel.image;
        } else if (imageModel.imagePath) {
            _cellImageView.image = [UIImage imageNamed:imageModel.imagePath];
        }
    }
}

-(YYAnimatedImageView *)cellImageView
{
    if (!_cellImageView) {
        _cellImageView = ({
            YYAnimatedImageView *image = [[YYAnimatedImageView alloc] init];
            image;
        });
    }
    return _cellImageView;
}

@end

#pragma mark - ============= ZFNewPushAllowTitleCell =============
@interface ZFCustomerTitleCell : UITableViewCell
<
    UITableViewCellProtocol
>
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation ZFCustomerTitleCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.contentLabel];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(32);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-32);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
    }
    return self;
}

-(void)setModel:(id<CustomerViewProtocol>)model
{
    _model = model;
    
    if ([_model isKindOfClass:[CustomerTitleModel class]]) {
        CustomerTitleModel *titleModel = (CustomerTitleModel *)_model;
        _contentLabel.text = titleModel.content;
        if (titleModel.contentTextAlignment) {
            _contentLabel.textAlignment = titleModel.contentTextAlignment;
        }
        if (titleModel.contentFont) {
            _contentLabel.font = titleModel.contentFont;
        }
        [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(model.edgeInsets.top);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(model.edgeInsets.left);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-model.edgeInsets.right);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-model.edgeInsets.bottom);
        }];
    }
    
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = @"TEST";
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 0;
            label;
        });
    }
    return _contentLabel;
}

@end

#pragma mark - ============= ZFNewPushAllowImageTitleCell =============
@interface ZFCustomerImageTitleCell : UITableViewCell
<
    UITableViewCellProtocol
>
@property (nonatomic, strong) YYAnimatedImageView *cellImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation ZFCustomerImageTitleCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.cellImageView];
        [self addSubview:self.contentLabel];
        
        [self.cellImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(24);
            make.centerY.mas_equalTo(self.contentLabel.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.cellImageView.mas_trailing).mas_offset(8);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-40);
            make.top.mas_equalTo(self.mas_top).mas_offset(16);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-4);
        }];
    }
    return self;
}

-(void)setModel:(id<CustomerViewProtocol>)model
{
    _model = model;
    
    if ([_model isKindOfClass:[CustomerImageTitleModel class]]) {
        CustomerImageTitleModel *imageTitleModel = (CustomerImageTitleModel *)_model;
        if (imageTitleModel.image) {
            _cellImageView.image = imageTitleModel.image;
        } else if (imageTitleModel.imagePath) {
            _cellImageView.image = [UIImage imageNamed:imageTitleModel.imagePath];
        }
        self.contentLabel.text = ZFToString(imageTitleModel.content);
    }
}

-(YYAnimatedImageView *)cellImageView
{
    if (!_cellImageView) {
        _cellImageView = ({
            YYAnimatedImageView *image = [[YYAnimatedImageView alloc] init];
            image;
        });
    }
    return _cellImageView;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:12];
            label.numberOfLines = 0;
            label;
        });
    }
    return _contentLabel;
}
@end

#pragma mark - ============= ZFNewPushAllowButtonCell =============

@interface ZFCustomerButtonCell : UITableViewCell
<
    UITableViewCellProtocol
>
@property (nonatomic, strong) UIButton *cellButton;
@end

@implementation ZFCustomerButtonCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.cellButton];
        
        [self.cellButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-2);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
            make.height.mas_equalTo(self.mas_width).multipliedBy(0.15);
        }];
    }
    return self;
}

-(void)setModel:(id<CustomerViewProtocol>)model
{
    _model = model;
    
    if ([_model isKindOfClass:[CustomerButtonModel class]]) {
        CustomerButtonModel *buttonModel = (CustomerButtonModel *)_model;
        [self.cellButton setTitle:buttonModel.buttonTitle forState:UIControlStateNormal];
        [self.cellButton setTitleColor:buttonModel.titleColor forState:UIControlStateNormal];
        self.cellButton.backgroundColor = buttonModel.buttonBackgroundColor;
        [self.cellButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(model.edgeInsets.top);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-model.edgeInsets.bottom);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
            make.height.mas_equalTo(self.mas_width).multipliedBy(0.15);
        }];
    }
}

- (void)buttonAction
{
    if (self.model.didClickItemBlock) {
        self.model.didClickItemBlock();
    }
}

-(UIButton *)cellButton
{
    if (!_cellButton) {
        _cellButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:@"TEST" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor blackColor];
            [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _cellButton;
}

@end

#pragma mark - ============= ZFCustomerCountDownButtonCell =============

@interface ZFCustomerCountDownButtonCell : UITableViewCell
<
    UITableViewCellProtocol
>
@property (nonatomic, strong) UIButton *cellButton;
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation ZFCustomerCountDownButtonCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.cellButton];
        
        [self.cellButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-2);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
            make.height.mas_equalTo(self.mas_width).multipliedBy(0.15);
        }];
    }
    return self;
}

-(void)setModel:(id<CustomerViewProtocol>)model
{
    _model = model;
    
    if ([_model isKindOfClass:[CustomerCountDownButtonModel class]]) {
        CustomerCountDownButtonModel *buttonModel = (CustomerCountDownButtonModel *)_model;
        if (buttonModel.countDown > 0) {
            __block NSInteger countDown = buttonModel.countDown;
            self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 1.0 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(self.timer, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (countDown == 0) {
                        [self buttonAction];
                        return;
                    }
                    NSString *countDownTitle = [NSString stringWithFormat:@"%@ (%lds)", buttonModel.buttonTitle, countDown];
                    countDown -= 1;
                    [self.cellButton setTitle:countDownTitle forState:UIControlStateNormal];
                });
            });
            dispatch_resume(self.timer);
        }
        [self.cellButton setTitleColor:buttonModel.titleColor forState:UIControlStateNormal];
        self.cellButton.backgroundColor = buttonModel.buttonBackgroundColor;
        [self.cellButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(model.edgeInsets.top);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-model.edgeInsets.bottom);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
            make.height.mas_equalTo(self.mas_width).multipliedBy(0.15);
        }];
    }
}

- (void)buttonAction
{
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
    if (self.model.didClickItemBlock) {
        self.model.didClickItemBlock();
    }
}

-(UIButton *)cellButton
{
    if (!_cellButton) {
        _cellButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:@"TEST" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor blackColor];
            [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _cellButton;
}

@end

#pragma mark - 主视图

static  CGFloat padding = 32;

@interface ZFPopCustomerView ()
<
    ContentViewCellDelegate,
    UITableViewDelegate,
    UITableViewDataSource
>
@property (nonatomic, strong) UIView        *maskView;
@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) NSArray<id<CustomerViewProtocol>> *dataList;
@end

@implementation ZFPopCustomerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.edgeInsets = UIEdgeInsetsZero;
    [self addSubview:self.maskView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.tableView];
    
    self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    self.maskView.frame = self.bounds;
    
    self.contentView.frame = CGRectMake(padding, 0, KScreenWidth - padding * 2, KScreenHeight);;
    self.contentView.layer.cornerRadius = 15;
    self.contentView.layer.masksToBounds = YES;
    
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth - padding * 2, KScreenHeight);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskView)];
    [self.maskView addGestureRecognizer:tap];
}

#pragma mark - datasource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1 || section == 2) {
        return 24;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 10;
    }
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = ZFCOLOR_WHITE;
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = ZFCOLOR_WHITE;
    return footerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<CustomerViewProtocol>cellModel = self.dataList[indexPath.row];
    id<UITableViewCellProtocol>cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellModel.class)];
    cell.model = cellModel;
    cell.delegate = self;
    UITableViewCell *customerCell = (UITableViewCell *)cell;
    return customerCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.contentViewBackgroundColor) {
        cell.backgroundColor = [UIColor clearColor];//self.contentViewBackgroundColor;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(popCustomerViewDidSelect:indexPath:)]) {
        [self.delegate popCustomerViewDidSelect:tableView indexPath:indexPath];
    }
}

#pragma mark - public method

-(void)showCustomer:(NSArray<id<CustomerViewProtocol>> *)customerViews
{
    if (![self superview]) {
        [WINDOW addSubview:self];
    }
    if (![self.contentView superview]) {
        [self addSubview:self.contentView];
    }
    
    if (![self.tableView superview]) {
        [self.contentView addSubview:self.tableView];
    }
    
    self.dataList = customerViews;
    
    //设置全屏来获取总cell,
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth - padding * 2, KScreenHeight);
    self.contentView.frame = CGRectMake(padding, 0, KScreenWidth - padding * 2, KScreenHeight);
    [self.tableView reloadData];
    
    CGFloat totalHeight = 0;
    //方法一
    /**
     NSArray *listCell = [self.tableView visibleCells];
     //需要调用一下 visibleCells， 不然可能indexPathsForVisibleRows取得不准
     NSArray *list = [self.tableView indexPathsForVisibleRows];
     for (NSIndexPath *indexPath in list) {
     CGFloat height = [self.tableView rectForRowAtIndexPath:indexPath].size.height;
     totalHeight += height;
     }
     */
    
    //方法二
    NSInteger sections = self.tableView.numberOfSections;
    for (int section = 0; section < sections; section++) {
        NSInteger rows =  [self.tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            CGFloat height = [self.tableView rectForRowAtIndexPath:indexPath].size.height;
            totalHeight += height;
        }
    }

    CGRect oldFrame = self.tableView.frame;
    if (totalHeight > KScreenHeight) {
        totalHeight = 450;
    }
    self.tableView.frame = CGRectMake(0, 0, oldFrame.size.width, totalHeight);
    self.contentView.frame = CGRectMake(padding, oldFrame.origin.y, oldFrame.size.width, totalHeight);
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.edgeInsets, UIEdgeInsetsZero)) {
        totalHeight = totalHeight + self.edgeInsets.bottom;
        self.contentView.frame = CGRectMake(padding, oldFrame.origin.y, oldFrame.size.width, totalHeight);
    }
    
    if (self.contentViewBackgroundColor) {
        self.tableView.backgroundColor = [UIColor clearColor];
    }
    
    if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
        self.tableView.showsVerticalScrollIndicator = YES;
        self.tableView.bounces = YES;
    }
    
    [UIView animateWithDuration:.3 animations:^{
        CGFloat y = (KScreenHeight - totalHeight)/2;
        self.contentView.frame = CGRectMake(padding, y, oldFrame.size.width, totalHeight);
        self.maskView.alpha = 0.5;
    }];
}

- (void)hiddenCustomer
{
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.0;
        self.contentView.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (self.superview) {
            [self removeFromSuperview];
        }
        self.contentView.alpha = 1.0;
    }];
}

#pragma mark - target action

- (void)tapMaskView
{
    [self hiddenCustomer];
}

#pragma mark - setter and getter

-(void)setContentViewBackgroundColor:(UIColor *)contentViewBackgroundColor
{
    _contentViewBackgroundColor = contentViewBackgroundColor;
    
    self.contentView.backgroundColor = _contentViewBackgroundColor;
}

-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor blackColor];
            view.alpha = 0.0;
            view;
        });
    }
    return _maskView;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            tableView.showsVerticalScrollIndicator = NO;
            tableView.showsHorizontalScrollIndicator = NO;
            tableView.estimatedRowHeight = 112;
            tableView.rowHeight = UITableViewAutomaticDimension;
            tableView.separatorStyle = NO;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.bounces = NO;
            tableView.layer.cornerRadius = 15;
            
            [tableView registerClass:[ZFCustomerImageCell class] forCellReuseIdentifier:NSStringFromClass([CustomerImageModel class])];
            [tableView registerClass:[ZFCustomerTitleCell class] forCellReuseIdentifier:NSStringFromClass([CustomerTitleModel class])];
            [tableView registerClass:[ZFCustomerImageTitleCell class] forCellReuseIdentifier:NSStringFromClass([CustomerImageTitleModel class])];
            [tableView registerClass:[ZFCustomerButtonCell class] forCellReuseIdentifier:NSStringFromClass([CustomerButtonModel class])];
            [tableView registerClass:[ZFCustomerCountDownButtonCell class] forCellReuseIdentifier:NSStringFromClass([CustomerCountDownButtonModel class])];
            [tableView registerClass:[ZFCustomerSelectMarkCell class] forCellReuseIdentifier:NSStringFromClass([CustomerSelectMarkModel class])];
            
            tableView;
        });
    }
    return _tableView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _contentView;
}

@end


#pragma mark - customerModel

//纯图片
@implementation CustomerImageModel
@synthesize edgeInsets = _edgeInsets;
@synthesize didClickItemBlock = _didClickItemBlock;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

@end

//纯文字内容
@implementation CustomerTitleModel
@synthesize edgeInsets = _edgeInsets;
@synthesize didClickItemBlock = _didClickItemBlock;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(16, 0, 6, 0);
    }
    return self;
}

@end

//图片和文字
@implementation CustomerImageTitleModel
@synthesize edgeInsets = _edgeInsets;
@synthesize didClickItemBlock = _didClickItemBlock;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

@end

//按钮
@implementation CustomerButtonModel
@synthesize edgeInsets = _edgeInsets;
@synthesize didClickItemBlock = _didClickItemBlock;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.buttonBackgroundColor = [UIColor blackColor];
        self.titleColor = [UIColor whiteColor];
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

@end

//倒计时按钮
@implementation CustomerCountDownButtonModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.buttonBackgroundColor = [UIColor blackColor];
        self.titleColor = [UIColor whiteColor];
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

@end

//选择视图模型
@implementation CustomerSelectMarkModel
@synthesize edgeInsets = _edgeInsets;
@synthesize didClickItemBlock = _didClickItemBlock;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isSelect = NO;
    }
    return self;
}

@end
