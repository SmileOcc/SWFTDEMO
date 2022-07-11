//
//  STLAlertMenuView.m
// XStarlinkProject
//
//  Created by odd on 2021/6/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLAlertMenuView.h"


@interface STLAlertMenuTableCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel     *msgLabel;
@property (nonatomic, strong) UIView      *lineView;

@end

@implementation STLAlertMenuTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        [self.contentView addSubview:self.imgView];
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.lineView];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(15);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.imgView.mas_trailing).mas_offset(9);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(0.5);
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

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _msgLabel.font = [UIFont systemFontOfSize:14];
        _msgLabel.numberOfLines = 2;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _msgLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _msgLabel;
}


- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}
@end

@interface STLAlertMenuView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) CGFloat      offset;
@property (nonatomic, assign) NSInteger    direct;
@property (nonatomic, assign) CGFloat      arrowH;
@property (nonatomic, assign) CGFloat      arrowW;

@property (nonatomic, strong) UITableView  *tableView;

@property (nonatomic, strong) NSArray      *images;
@property (nonatomic, strong) NSArray      *titles;
@property (nonatomic, strong) UIView       *bgControlView;

@property (nonatomic, strong) UIView       *dotView;

@property (nonatomic, weak) STLAlertMenuView *weakMenuView;

@end

@implementation STLAlertMenuView


+ (instancetype)sharedInstance
{
    static STLAlertMenuView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STLAlertMenuView alloc] init];
    });
    return instance;
}
- (instancetype)initTipArrowOffset:(CGFloat)offset
                            direct:(STLMenuArrowDirect)direct
                           images:(NSArray *)images
                            titles:(NSArray *)titles {
    
    self = [super init];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlClearColor];
        
        self.layer.shadowColor = [OSSVThemesColors col_000000:0.2].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 10;
        
        self.alpha = 0;
        self.tableView.alpha = 0;

        
        self.offset = offset;
        self.direct = direct;
        self.arrowW = 8.0;
        self.arrowH = 4.0;
        
        self.images = images;
        self.titles = titles;
        if (!STLJudgeNSArray(images)) {
            self.images = @[];
        }
        if (!STLJudgeNSArray(titles)) {
            self.titles = @[];
        }
        
        self.tableView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self addSubview:self.tableView];
        [self addSubview:self.dotView];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.mas_top).offset(self.arrowH);
        }];
        
        self.dotView.frame = CGRectMake(1, 0, 1, 1);
        [self.tableView reloadData];
    }
    return self;
}

- (void)actionTap {
    [self dismiss];
}

#pragma mark tableViewDelegate & dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STLAlertMenuTableCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(STLAlertMenuTableCell.class) forIndexPath:indexPath];
    if (self.titles.count > indexPath.row) {
        cell.msgLabel.text = self.titles[indexPath.row];
        cell.imgView.image = [UIImage imageNamed:STLToString(self.images[indexPath.row])];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self dismiss];
    if (self.selectBlock) {
        self.selectBlock(indexPath.row);
    }
}


- (void)dismiss {
    [UIView animateWithDuration: 0.25 animations:^{
        self.alpha = 0;
        _tableView.alpha = 0;
    } completion:^(BOOL finished) {

        [self.bgControlView removeFromSuperview];
        [self removeFromSuperview];
        [_tableView removeFromSuperview];
    }];
    
}

+ (void)removeMenueView {
//    NSArray *subS = WINDOW.subviews;
//    for (UIView *subView in subS) {
//        if ([subView isKindOfClass:[STLAlertMenuView class]]) {
//            STLAlertMenuView *menuView = (STLAlertMenuView *)subView;
//            [menuView.bgControlView removeFromSuperview];
//            [menuView.tableView removeFromSuperview];
//            [subView removeFromSuperview];
//        }
//    }
    
    STLAlertMenuView *menuView = [STLAlertMenuView sharedInstance].weakMenuView;
    if (menuView) {
        [menuView.bgControlView removeFromSuperview];
        [menuView.tableView removeFromSuperview];
        [menuView removeFromSuperview];
        menuView = nil;
    }
}

- (void)showSourceView:(UIView *)sourceView {
    if (!sourceView || !sourceView.superview) {
        return;
    }
    
    //为什么就不能用WINDOW,这难受的阿语（语言切换时，有问题）
    UIView *ctrView = [UIViewController currentTopViewController].view;

    for (UIView *subView in ctrView.subviews) {
        if ([subView isKindOfClass:[STLAlertMenuView class]]) {
            STLAlertMenuView *menuView = (STLAlertMenuView *)subView;
            [menuView.bgControlView removeFromSuperview];
            [subView removeFromSuperview];
        }
    }
    
    [STLAlertMenuView sharedInstance].weakMenuView = self;

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
    self.bgControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.bgControlView.backgroundColor = [UIColor clearColor];
    [self.bgControlView addGestureRecognizer:tap];
    [ctrView addSubview:self.bgControlView];
    
    [ctrView addSubview:self];
    
    CGRect soureceRect = [STLAlertMenuView sourceViewFrameToWindow:sourceView];

    CGFloat SoucceCenterXLeftspace = SCREEN_WIDTH - (soureceRect.origin.x + soureceRect.size.width / 2.0);
    
    CGFloat dotx = CGRectGetMinX(self.dotView.frame);
    STLLog(@"--yyyyyyy: %f",dotx);
    //阿语坐标怎么是从左到右？？？
    if ([OSSVSystemsConfigsUtils isRightToLeftShow] && dotx <= 1.1) {
        SoucceCenterXLeftspace = soureceRect.origin.x;
    }
    
    CGFloat moveX = 0;
    CGFloat moveOffset = 148 / 2.0;
    CGFloat minSpace = 12;
    if (self.offset >= 0) {
        moveOffset = self.offset;
    }
    if (self.direct == STLMenuArrowDirectUpRight || self.direct == STLMenuArrowDirectDownRight) {
        moveX = SoucceCenterXLeftspace - moveOffset;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            moveX = SoucceCenterXLeftspace + moveOffset;
        }
        
        if (moveX < minSpace) {
            self.offset = moveOffset + moveX - minSpace,
            moveX = 12;
        }
    } else if (self.direct == STLMenuArrowDirectUpLeft || self.direct == STLMenuArrowDirectDownLeft) {
        moveX = SoucceCenterXLeftspace - (148 - moveOffset);
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            moveX = SoucceCenterXLeftspace;
        }
        
        if (moveX < minSpace) {
            self.offset = moveOffset - moveX + minSpace,
            moveX = 12;
        }
    }
    
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ctrView.mas_top).mas_offset((soureceRect.origin.y + soureceRect.size.height));
        make.trailing.mas_equalTo(ctrView.mas_trailing).mas_offset(-moveX);
        make.size.mas_equalTo(CGSizeMake(148, 44 * 3 + 4));
    }];
    
    //self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration: 0.25 animations:^{
        //self.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1;
        _tableView.alpha = 1;
    } completion:^(BOOL finished) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuDidShow)]) {
//            [self.delegate ybPopupMenuDidShow];
//        }
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = OSSVThemesColors.col_F1F1F1;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        [_tableView registerClass:[STLAlertMenuTableCell class] forCellReuseIdentifier:NSStringFromClass(STLAlertMenuTableCell.class)];
    }
    return _tableView;
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] initWithFrame:CGRectZero];
        _dotView.hidden = YES;
    }
    return _dotView;
}

+ (CGRect)sourceViewFrameToWindow:(UIView *)sourceView {
    if (sourceView.superview) {
        return [sourceView.superview convertRect:sourceView.frame toView:WINDOW];
    }
    return CGRectZero;
}


- (void)drawRect:(CGRect)rect {
    CGRect frame = rect;
    
    CGFloat frameWidth = CGRectGetWidth(frame);
    CGFloat frameHeight = CGRectGetHeight(frame);
    //箭头宽、高
    CGFloat arrowW = self.arrowW;
    CGFloat arrowH = self.arrowH;
    
    //FIXME: occ Bug 1101 完善待
    CGFloat arcR = 5;

    CGFloat moveOffset = 0.0;
    CGFloat moveDirect = self.direct;
    if (self.offset >= 0) {
        moveOffset = self.offset;
    } else {
        if (moveDirect == STLMenuArrowDirectUpRight || moveDirect == STLMenuArrowDirectUpLeft
            || moveDirect == STLMenuArrowDirectDownLeft || moveDirect == STLMenuArrowDirectDownRight) {
            moveOffset = frameWidth / 2.0;
        } else {
            moveOffset = frameHeight / 2.0;
        }
    }
    if (moveOffset < arrowW / 2.0) {
        moveOffset = arrowW / 2.0;
    }
    
    // 设置最新圆角
    if ((moveOffset - arrowW / 2.0) < arcR) {
        arcR = moveOffset - arrowW / 2.0;
    }
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [[UIColor colorWithWhite:0 alpha:0.0] set];
    
    if (moveDirect == STLMenuArrowDirectUpRight || moveDirect == STLMenuArrowDirectUpLeft) {
        
        CGContextMoveToPoint(contextRef, 0.0, arrowH + arcR);
        
        //弧线
        CGContextAddArcToPoint(contextRef, 0, arrowH, arcR, arrowH, arcR);
        
        if (moveDirect == STLMenuArrowDirectUpLeft) {
            CGContextAddLineToPoint(contextRef, moveOffset - arrowW / 2.0, arrowH);
            CGContextAddLineToPoint(contextRef, moveOffset, 0.0);
            CGContextAddLineToPoint(contextRef, moveOffset + arrowW / 2.0, arrowH);
        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth - (arrowW / 2.0 + moveOffset), arrowH);
            CGContextAddLineToPoint(contextRef, frameWidth -  moveOffset, 0.0);
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset - arrowW / 2.0), arrowH);
        }
        
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, arrowH, frameWidth, arrowH + arcR, arcR);
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight - arcR);
        
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, frameHeight, frameWidth - arcR, frameHeight, arcR);
        CGContextAddLineToPoint(contextRef, arcR, frameHeight);
        //弧线
        CGContextAddArcToPoint(contextRef, 0, frameHeight, 0, frameHeight - arcR, arcR);
        CGContextAddLineToPoint(contextRef, 0.0, arrowH + arcR);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
        
    }
    
    else if (moveDirect == STLMenuArrowDirectDownLeft || moveDirect == STLMenuArrowDirectDownRight) {
        
        CGContextMoveToPoint(contextRef, 0.0, arcR);
        //弧线
        CGContextAddArcToPoint(contextRef, 0, 0, arcR, 0, arcR);
        CGContextAddLineToPoint(contextRef, frameWidth - arcR, 0);
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, 0, frameWidth, arcR, arcR);
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight - arrowH - arcR);
        
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, frameHeight - arrowH, frameWidth - arcR, frameHeight - arrowH, arcR);
        
        if (moveDirect == STLMenuArrowDirectDownLeft) {
            CGContextAddLineToPoint(contextRef, moveOffset + arrowW / 2.0, frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, moveOffset, frameHeight);
            CGContextAddLineToPoint(contextRef, moveOffset - arrowW / 2.0, frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, arcR, frameHeight - arrowH);
            
        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset - arrowW / 2.0), frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, frameWidth -  moveOffset, frameHeight);
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset + arrowW / 2.0), frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, arcR, frameHeight - arrowH);
        }
        
        //弧线
        CGContextAddArcToPoint(contextRef, 0, frameHeight - arrowH, 0, frameHeight - arrowH - arcR, arcR);
        CGContextAddLineToPoint(contextRef, 0.0, arcR);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
    }
    
    else if (moveDirect == STLMenuArrowDirectLeftUp || moveDirect == STLMenuArrowDirectLeftDown) {
        
        CGContextMoveToPoint(contextRef, arrowH, 0.0);
        
        if (moveDirect == STLMenuArrowDirectLeftUp) {
            CGContextAddLineToPoint(contextRef, arrowH, moveOffset - arrowW / 2.0);
            CGContextAddLineToPoint(contextRef, 0, moveOffset);
            CGContextAddLineToPoint(contextRef, arrowH, moveOffset + arrowW / 2.0);
            
        } else {
            CGContextAddLineToPoint(contextRef, arrowH, frameHeight - (moveOffset + arrowW / 2.0));
            CGContextAddLineToPoint(contextRef, 0, frameHeight - moveOffset);
            CGContextAddLineToPoint(contextRef, arrowH, frameHeight -(moveOffset - arrowW / 2.0));
        }
        
        CGContextAddLineToPoint(contextRef, arrowH, frameHeight);
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight);
        CGContextAddLineToPoint(contextRef, frameWidth, 0);
        CGContextAddLineToPoint(contextRef, arrowH, 0);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
        
    }
    
    else if (moveDirect == STLMenuArrowDirectRightUp || moveDirect == STLMenuArrowDirectRightDown) {
        
        CGContextMoveToPoint(contextRef, 0.0, 0.0);
        CGContextAddLineToPoint(contextRef, frameWidth - arrowH, 0);
        
        if (moveDirect == STLMenuArrowDirectRightUp) {
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, moveOffset - arrowW / 2.0);
            CGContextAddLineToPoint(contextRef, frameWidth, moveOffset);
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, moveOffset + arrowW / 2.0);
            
        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, frameHeight - (moveOffset + arrowW / 2.0));
            CGContextAddLineToPoint(contextRef, frameWidth, frameHeight - moveOffset);
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, frameHeight - (moveOffset - arrowW / 2.0));
        }
        
        CGContextAddLineToPoint(contextRef, frameWidth - arrowH, frameHeight);
        CGContextAddLineToPoint(contextRef, 0, frameHeight);
        CGContextAddLineToPoint(contextRef, 0, 0);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
        
    }
}
@end
