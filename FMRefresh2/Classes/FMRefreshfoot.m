//
//  FMRefreshfoot.m
//  FMRefresh
//
//  Created by qianjn on 2016/10/28.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "FMRefreshfoot.h"

#define k_FMRefresh_Height 60   //控件的高度
#define k_FMRefresh_Width [UIScreen mainScreen].bounds.size.width //控件的宽度

typedef NS_ENUM(NSInteger, FMRefreshState) {
    FMRefreshStateNormal = 0,     /** 普通状态 */
    FMRefreshStatePulling,        /** 释放刷新状态 */
    FMRefreshStateRefreshing,     /** 正在刷新 */
};

@interface FMRefreshfoot ()

@property (assign, nonatomic) id refreshTarget;
@property (nonatomic, assign) SEL refreshAction;

@property (nonatomic, strong) UIScrollView *superScrollView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) NSArray *refreshImages;

@property (nonatomic,assign) FMRefreshState currentState;

@property (nonatomic, assign) BOOL noMoreData;
@end

@implementation FMRefreshfoot

- (instancetype)initWithTargrt:(id)target refreshAction:(SEL)refreshAction
{
    CGRect newFrame = CGRectMake(0, 0, k_FMRefresh_Width-5, k_FMRefresh_Height);
    self = [super initWithFrame:newFrame];
    if (self) {
        self.refreshTarget = target;
        self.refreshAction = refreshAction;
        
        [self buildUI];
        
    }
    return self;
}



- (void)buildUI
{
    self.backgroundColor = [UIColor brownColor];
    
    UIImage *image = [UIImage imageNamed:@"refresh_1"];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    
    [self addSubview:self.imageView];
    
    self.label = [[UILabel alloc] init];
    self.label.textColor = [UIColor darkGrayColor];
    self.label.font = [UIFont systemFontOfSize:16];
    self.label.text = NSLocalizedString(FM_Refresh_foot_normal_title, nil);;
    [self.label sizeToFit];
    [self addSubview:self.label];
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.currentState = FMRefreshStateNormal;
    
    [self updateFrame];
}

- (void)updateFrame
{
    if(self.noMoreData) {
        return;
    }
    CGFloat totalWidth = 35 + 20 + self.label.bounds.size.width;
    CGFloat imageViewX = (k_FMRefresh_Width - totalWidth)/2;
    self.imageView.frame = CGRectMake(imageViewX, 10, 35, 35);
    self.label.frame = CGRectMake(imageViewX + 35 + 20, (k_FMRefresh_Height - self.label.bounds.size.height)/2, self.label.bounds.size.width, self.label.bounds.size.height);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if ([newSuperview isKindOfClass:[UIScrollView class]] ) {
        self.superScrollView = (UIScrollView *)newSuperview;
        [self.superScrollView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
        [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
   
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGRect frame = self.frame;
        frame.origin.y = self.superScrollView.contentSize.height;
        self.frame = frame;
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGFloat topOffset = self.superScrollView.contentSize.height - self.superScrollView.frame.size.height;
        if (self.superScrollView.isDragging) {

            CGFloat pullDistance = self.superScrollView.contentOffset.y - topOffset;
            if (pullDistance > 0 && pullDistance < k_FMRefresh_Height && self.currentState == FMRefreshStatePulling) {
                NSLog(@"切换到normal");
                self.currentState = FMRefreshStateNormal;
            } else if (pullDistance >= k_FMRefresh_Height && self.currentState == FMRefreshStateNormal) {
                NSLog(@"切换到pulling");
                self.currentState = FMRefreshStatePulling;
            }
 
        } else {

            if (self.currentState == FMRefreshStatePulling) {
                NSLog(@"切换到refreshing");
                self.currentState = FMRefreshStateRefreshing;
            }
        }
        [self updateFrame];
    }
}


- (void)setCurrentState:(FMRefreshState)currentState
{
    if (self.noMoreData) {
        return;
    }
    _currentState = currentState;
    
    switch (_currentState) {
        case FMRefreshStateNormal:
            self.label.text = NSLocalizedString(FM_Refresh_foot_normal_title, nil);
            [self.label sizeToFit];
            
            break;
        case FMRefreshStatePulling:
            self.label.text = NSLocalizedString(FM_Refresh_foot_pulling_title, nil);
            [self.label sizeToFit];
            
            break;
        case FMRefreshStateRefreshing:
            self.label.text = NSLocalizedString(FM_Refresh_foot_Refreshing_title, nil);;
            [self.label sizeToFit];
            self.imageView.animationImages = self.refreshImages;
            self.imageView.animationDuration = 5;
            [self.imageView startAnimating];

            UIEdgeInsets contentInset = self.superScrollView.contentInset;
            contentInset.bottom = contentInset.bottom + k_FMRefresh_Height;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.superScrollView.contentInset = contentInset;
            } completion:^(BOOL finished) {
                
                [self doRefreshAction];
            }];
            
            break;
    }
}



- (void)doRefreshAction
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.refreshTarget && [self.refreshTarget respondsToSelector:self.refreshAction])
        [self.refreshTarget performSelector:self.refreshAction];
#pragma clang diagnostic pop
    
}

- (void)endRefreshing {
    if (self.currentState == FMRefreshStateRefreshing) {
        [self.imageView stopAnimating];
        UIEdgeInsets contentInset = self.superScrollView.contentInset;
        contentInset.bottom = contentInset.bottom - k_FMRefresh_Height;
        self.superScrollView.contentInset = contentInset;
        
        self.currentState = FMRefreshStateNormal;
    }
}

- (NSArray *)refreshImages {
    if (_refreshImages == nil) {
        NSMutableArray *arrayM = [NSMutableArray array];
        
        for (int i = 1; i < 20; i++) {
            NSString *imageName = [NSString stringWithFormat:@"refresh_%d", i];
            UIImage *image = [UIImage imageNamed:imageName];
            
            [arrayM addObject:image];
        }
        
        _refreshImages = arrayM;
    }
    return _refreshImages;
}

- (void)endRefreshingWithNoMoreData
{
    self.noMoreData = YES;
    self.label.text = NSLocalizedString(@"no more data", nil);
    [self.label sizeToFit];
    self.imageView.hidden = YES;
    
    self.label.frame = CGRectMake((k_FMRefresh_Width - self.label.bounds.size.width)/2,
                                  (k_FMRefresh_Height - self.label.bounds.size.height)/2,
                                  self.label.bounds.size.width,
                                  self.label.bounds.size.height);
    
}

- (void)dealloc {
    [self.superScrollView removeObserver:self forKeyPath:@"contentSize"];
    [self.superScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

@end
