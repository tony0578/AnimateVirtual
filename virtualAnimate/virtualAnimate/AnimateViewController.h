//
//  ViewController.h
//  virtualAnimate
//
//  Created by 汤维炜 on 16/5/10.
//  Copyright © 2016年 Tommy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    sliderType = 0,
    cycleType,
} UIType;

@interface AnimateViewController : UIViewController

@property (nonatomic, assign ) UIType           uitype;
@end

