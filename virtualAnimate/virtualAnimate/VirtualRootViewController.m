//
//  VirtualRootViewController.m
//  virtualAnimate
//
//  Created by 汤维炜 on 16/5/10.
//  Copyright © 2016年 Tommy. All rights reserved.
//

#import "VirtualRootViewController.h"
#import "AnimateViewController.h"

@implementation VirtualRootViewController
- (void)viewDidLoad {

    [super viewDidLoad];
    
    UIButton *sliderVirtual = [self buttonWithMarginTop:200.f title:@"slider animate"];
    [sliderVirtual addTarget:self action:@selector(sliderButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *cycleVirtual = [self buttonWithMarginTop:350 title:@"cycleAnimate"];
    [cycleVirtual addTarget:self action:@selector(cycleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)sliderButtonClicked:(UIButton *)sender {
    AnimateViewController *ctr = [AnimateViewController new];
    ctr.uitype = 0;
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)cycleButtonClicked:(UIButton *)sender {
    AnimateViewController *ctr = [AnimateViewController new];
    ctr.uitype = 1;
    [self.navigationController pushViewController:ctr animated:YES];

}


- (UIButton *)buttonWithMarginTop:(CGFloat)marginTop title:(NSString *)title{

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 180, 40);
    btn.center = CGPointMake(self.view.center.x, 100+marginTop/2);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTintColor:[UIColor yellowColor]];
    btn.backgroundColor = [UIColor purpleColor];
    btn.layer.cornerRadius = 20;
    [self.view addSubview:btn];
    
    return btn;
}
@end
