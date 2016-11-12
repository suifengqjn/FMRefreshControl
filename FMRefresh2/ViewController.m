//
//  ViewController.m
//  FMRefresh2
//
//  Created by qianjn on 2016/10/28.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "ViewController.h"
#import "RootTableViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 100);
    [button setTitle:@"UIRefreshControl" forState:UIControlStateNormal];
    button.backgroundColor =[UIColor brownColor];
    [button addTarget:self action:@selector(ButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    

    
}



- (void)ButtonClick
{
    RootTableViewController *CUS = [RootTableViewController new];
    [self.navigationController pushViewController:CUS animated:YES];
}



@end
