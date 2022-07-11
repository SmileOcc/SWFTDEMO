//
//  OSSVSortsOptionalView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSortsOptionalView.h"
#import "UIImage+STLCategory.h"

@implementation OSSVSortsOptionalView


#pragma  mark - public methods

-(void)show:(BOOL)flag
{
    if (flag)
    {
        [self updateState:SortOptionalStateOpen];
    }
    else
    {
        [self updateState:SortOptionalStateClose];
    }
}

- (void)dismiss
{
    self.optionalState = SortOptionalStateCloseAnimating;
    self.optionTable.userInteractionEnabled = false;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.optionTable.frame;
        frame.size.height = 0;
        self.optionTable.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.optionalState = SortOptionalStateClose;
    }];
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.hidden = true;
        [self addSubview:self.optionTable];
        self.optionTable.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        
        [self addSubview:self.topLienView];
        self.topLienView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0.5);
        
        [self addGestureRecognizer:self.tapGesture];
    }
    return self;
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
      shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
    {//判断如果点击的是tableView的cell，就把手势给关闭了
        return NO;//关闭手势
    }//否则手势存在
    return YES;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource &&
        [self.dataSource respondsToSelector:@selector(datasYSSortOptionalView)])
    {
        return [self.dataSource datasYSSortOptionalView].count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"STLSortOptionalViewCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"STLSortOptionalViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLab.tag = 120001;
        titleLab.textColor = [OSSVThemesColors col_0D0D0D];
        titleLab.font = [UIFont systemFontOfSize:13];
        [cell addSubview:titleLab];
        
        UIButton  *markBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        markBtn.tag = 120002;
        [markBtn setImage:[UIImage imageNamed:@"select_mark"]  forState:UIControlStateNormal];
        [cell addSubview:markBtn];
        
//        UIView  *lineView = [[UIView alloc] initWithFrame:CGRectZero];
//        lineView.backgroundColor = OSSVThemesColors.col_EDEDED;
//        [cell addSubview:lineView];
        
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(cell.mas_leading).mas_offset(15);
            make.centerY.mas_equalTo(cell.mas_centerY);
        }];
        
        [markBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(cell.mas_trailing).mas_offset(-15);
            make.centerY.mas_equalTo(cell.mas_centerY);
        }];
        
//        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.trailing.bottom.mas_equalTo(cell);
//            make.leading.mas_equalTo(cell.mas_leading).mas_offset(15);
//            make.height.mas_equalTo(0.5);
//        }];
    }
    
    UILabel *titleLab = [cell viewWithTag:120001];
    UIButton  *markBtn = [cell viewWithTag:120002];
    titleLab.text = @"";
    markBtn.hidden = true;
    
    if (self.dataSource
        && [self.dataSource respondsToSelector:@selector(datasYSSortOptionalView)])
    {
        NSArray *datas = [self.dataSource datasYSSortOptionalView];
        if (datas.count > indexPath.row) {
            titleLab.text = datas[indexPath.row];
            
            if (indexPath.row == self.selectIndex) {
                markBtn.hidden = false;
                titleLab.font = [UIFont boldSystemFontOfSize:13];
            }
            else {
                titleLab.font = [UIFont systemFontOfSize:13];
            }
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndex = indexPath.row;
    [self.optionTable reloadData];
    
    // [self show:false] 直接调这个方法，表刷新时内容会消失
    [self performSelector:@selector(cancelTouch) withObject:nil afterDelay:0.01];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sortOptinalView:selectIndex:)])
    {
        [self.delegate sortOptinalView:self selectIndex:indexPath.row];
    }
}

#pragma mark - user action

//关闭收回窗口
- (void)cancelTouch
{
    [self show:false];
}

#pragma mark - private methods
//更改动画状态
- (void)updateState:(SortOptionalState) state
{
    
    //动画过程中,不处理事件
    if (state == SortOptionalStateOpen && self.optionalState == SortOptionalStateOpenAnimating)
    {
        return;
    }
    if (state == SortOptionalStateClose && self.optionalState == SortOptionalStateCloseAnimating)
    {
        return;
    }
    
    if (state == SortOptionalStateOpen && self.optionalState != state)
    { //打开动画
        self.optionalState = SortOptionalStateOpenAnimating;

        self.hidden = NO;
        self.optionTable.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.optionTable.frame;
            frame.size.height = 4 * 44;
            self.optionTable.frame = frame;
            self.backgroundColor = [OSSVThemesColors col_000000:0.3];
        } completion:^(BOOL finished) {
            self.optionalState = SortOptionalStateOpen;
            self.optionTable.userInteractionEnabled = true;
        }];
        
    }
    else if (state == SortOptionalStateClose && self.optionalState != state)
    { //关闭动画
        if (self.delegate && [self.delegate respondsToSelector:@selector(sortOptinalView:selectIndex:)])
        {
            [self.delegate sortOptinalView:self selectIndex:self.selectIndex];
        }
        [self dismiss];
    }
}


#pragma mark - setter / getter

- (UIView *)topLienView
{
    if (!_topLienView)
    {
        _topLienView = [[UIView alloc] initWithFrame:CGRectZero];
        _topLienView.backgroundColor = OSSVThemesColors.col_EDEDED;
    }
    return _topLienView;
}

- (UITableView *)optionTable
{
    if (!_optionTable)
    {
        _optionTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _optionTable.delegate = self;
        _optionTable.dataSource = self;
        _optionTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _optionTable;
}

- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture)
    {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelTouch)];
        _tapGesture.delegate=self;
    }
    return _tapGesture;
}


@end
