//
//  FMRefreshControl.m
//  FMRefresh2
//
//  Created by qianjn on 2016/10/31.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "FMRefreshControl.h"

#define k_FMRefresh_Height 60   //控件的高度
#define k_FMRefresh_Width [UIScreen mainScreen].bounds.size.width //控件的宽度
typedef NS_ENUM(NSInteger, FMRefreshState) {
    FMRefreshStateNormal = 0,     /** 普通状态 */
    FMRefreshStatePulling,        /** 释放刷新状态 */
    FMRefreshStateRefreshing,     /** 正在刷新 */
};

@interface FMRefreshControl ()
@property (nonatomic, assign) CGFloat originalOffsetY;
@property (nonatomic, strong) UIView  *backgroundView;

@property (assign, nonatomic) id refreshTarget;
@property (nonatomic, assign) SEL refreshAction;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, assign) FMRefreshState currentStatus;

@property (nonatomic, strong) UIScrollView *superScrollView;

@property (nonatomic, strong) NSArray *refreshingImages;

@end

@implementation FMRefreshControl

- (instancetype)initWithTargrt:(id)target refreshAction:(SEL)refreshAction
{
    self = [super initWithFrame:CGRectMake(0, -60, k_FMRefresh_Width, 60)];
    if (self) {
        self.refreshTarget = target;
        self.refreshAction = refreshAction;
        [self buildUI];
    }
    return self;
}


#pragma makr - View
- (void)buildUI
{
    self.tintColor = [UIColor clearColor];
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, k_FMRefresh_Width, k_FMRefresh_Height)];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backgroundView];
    
    UIImage *normalImage = [UIImage imageNamed:@"refresh_1"];
    self.imageView = [[UIImageView alloc] initWithImage:normalImage];
    [self.backgroundView addSubview:self.imageView];
    
    self.label = [[UILabel alloc] init];
    self.label.textColor = [UIColor darkGrayColor];
    self.label.font = [UIFont systemFontOfSize:16];
    self.label.text = NSLocalizedString(FM_Refresh_normal_title, nil);
    [self.label sizeToFit];
    [self.backgroundView addSubview:self.label];
    [self updateFrame];
   

}


- (void)updateFrame
{
    CGFloat totalWidth = 35 + 20 + self.label.bounds.size.width;
    CGFloat imageViewX = (k_FMRefresh_Width - totalWidth)/2;
    self.imageView.frame = CGRectMake(imageViewX, 15, 35, 35);
    self.label.frame = CGRectMake(imageViewX + 35 + 20, (k_FMRefresh_Height - self.label.bounds.size.height)/2, self.label.bounds.size.width, self.label.bounds.size.height);
}

- (NSArray *)refreshingImages {
    if (_refreshingImages == nil) {
        NSMutableArray *arrayM = [NSMutableArray array];
        for (int i = 1; i < 20; i++) {
            NSString *imageNmae = [NSString stringWithFormat:@"refresh_%d", i];
            
            UIImage *image = [UIImage imageNamed:imageNmae];
            [arrayM addObject:image];
        }
        
        _refreshingImages = arrayM;
    }
    return  _refreshingImages;
}

- (void)dealloc {
    
    [self.superScrollView removeObserver:self forKeyPath:@"contentOffset"];
}


#pragma mark - KVO
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView *)newSuperview;
        
        [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    
    if (self.superScrollView.isDragging && !self.isRefreshing) {
        if (!self.originalOffsetY) {
            self.originalOffsetY = -self.superScrollView.contentInset.top;
        }
        CGFloat normalPullingOffset =  self.originalOffsetY - k_FMRefresh_Height;
        if (self.currentStatus == FMRefreshStatePulling && self.superScrollView.contentOffset.y > normalPullingOffset) {
            
            self.currentStatus = FMRefreshStateNormal;
        } else if (self.currentStatus == FMRefreshStateNormal && self.superScrollView.contentOffset.y < normalPullingOffset) {
            self.currentStatus = FMRefreshStatePulling;
        }
    } else if(!self.superScrollView.isDragging){
        
        if (self.currentStatus == FMRefreshStatePulling) {
            
            self.currentStatus = FMRefreshStateRefreshing;
        }
    }

    CGFloat pullDistance = -self.frame.origin.y;
    //pullDistance = MIN(60, -self.frame.origin.y); 悬浮在顶部
    self.backgroundView.frame = CGRectMake(0, 0, k_FMRefresh_Width, pullDistance);
    CGFloat totalWidth = 35 + 20 + self.label.bounds.size.width;
    CGFloat imageViewX = (k_FMRefresh_Width - totalWidth)/2;
    
    self.imageView.frame = CGRectMake(imageViewX,  -k_FMRefresh_Height+pullDistance+(k_FMRefresh_Height - self.imageView.bounds.size.height)/2, self.imageView.frame.size.width, self.imageView.frame.size.height);
    self.label.frame = CGRectMake(imageViewX + 35 + 20, -k_FMRefresh_Height + pullDistance + (k_FMRefresh_Height - self.label.bounds.size.height)/2, self.label.frame.size.width, self.label.frame.size.height);
    
    
}

- (void)setCurrentStatus:(FMRefreshState)currentStatus {
    _currentStatus = currentStatus;
    switch (_currentStatus) {
        case FMRefreshStateNormal:
            NSLog(@"切换到Normal");
            [self.imageView stopAnimating];
            self.label.text = FM_Refresh_normal_title;
            [self.label sizeToFit];
            self.imageView.image = [UIImage imageNamed:@"refresh_1"];
            
            break;
        case FMRefreshStatePulling:
            NSLog(@"切换到Pulling");
            self.label.text = FM_Refresh_pulling_title;
            [self.label sizeToFit];
            self.imageView.animationImages = self.refreshingImages;
            self.imageView.animationDuration = 1.5;
            [self.imageView startAnimating];
            
            break;
        case FMRefreshStateRefreshing:
            NSLog(@"切换到Refreshing");
            self.label.text = FM_Refresh_Refreshing_title;
            [self.label sizeToFit];
            [self beginRefreshing];
            self.imageView.animationImages = self.refreshingImages;
            self.imageView.animationDuration = 1.5;
            [self.imageView startAnimating];
            [self doRefreshAction];
            
            break;
    }
}


#pragma mark - action

- (void)doRefreshAction
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.refreshTarget && [self.refreshTarget respondsToSelector:self.refreshAction])
        [self.refreshTarget performSelector:self.refreshAction];
#pragma clang diagnostic pop
    
}

- (void)beginRefreshing
{
    [super beginRefreshing];
}

- (void)endRefreshing {
    
    if (self.currentStatus != FMRefreshStateRefreshing) {
        return;
    }
    
    self.currentStatus = FMRefreshStateNormal;
    [super endRefreshing];
    
    //在执行刷新的状态中，用户手动拖动到 nornal 状态的 offset，[super endRefreshing] 无法回到初始位置，所以手动设置
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.superScrollView.contentOffset.y >= self.originalOffsetY - k_FMRefresh_Height && self.superScrollView.contentOffset.y <= self.originalOffsetY) {
            CGPoint offset = self.superScrollView.contentOffset;
            offset.y = self.originalOffsetY;
            [self.superScrollView setContentOffset:offset animated:YES];
        }
    });

}

@end
