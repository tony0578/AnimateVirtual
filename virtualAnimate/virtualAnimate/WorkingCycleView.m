//
//  Created by 汤维炜 on 16/5/10.
//  Copyright © 2016年 Tommy. All rights reserved.
//

#import "WorkingCycleView.h"

@interface WorkingCycleView()
{
    UIImageView *_imgview;
    NSTimer *_timer;
    CGFloat _angle;
}
@end

@implementation WorkingCycleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self drawBackgrounImageWithFrame:frame];
    }
    return self;
}

- (void)drawBackgrounImageWithFrame:(CGRect)frame {
    _imgview = [[UIImageView alloc]initWithFrame:frame];
    _imgview.image = [UIImage imageNamed:@"cycle"];
    [self addSubview:_imgview];
}

- (void)startAnimate {
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(startCyclingAnimate) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)stopAnimate {
    [_timer invalidate];
    _timer = nil;
}

- (void)startCyclingAnimate {
    _angle += 3;
    CATransform3D transform3d = CATransform3DMakeRotation(_angle*(M_PI/180.f), 0, 0, 1);
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:0.1];
    _imgview.layer.transform = transform3d;
    [UIView commitAnimations];
}



@end
