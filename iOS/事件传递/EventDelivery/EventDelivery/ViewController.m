//
//  ViewController.m
//  EventDelivery
//
//  Created by scott on 15/9/14.
//  Copyright © 2015年 xbdx. All rights reserved.
//

#import "ViewController.h"
#import <PureLayout.h>
#import "FirstView.h"
#import "SecondView.h"
#import "ThirdView.h"

@interface ViewController ()

@property (nonatomic,strong) FirstView *firstView;
@property (nonatomic,strong) SecondView *secondView;
@property (nonatomic,strong) ThirdView *thirdView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstView = [FirstView newAutoLayoutView];
    _secondView = [SecondView newAutoLayoutView];
    _thirdView = [ThirdView newAutoLayoutView];
    
    _firstView.backgroundColor = [UIColor redColor];
    _secondView.backgroundColor = [UIColor greenColor];
    _thirdView.backgroundColor = [UIColor blueColor];
    
    [_secondView addSubview:_firstView];
    [_thirdView addSubview:_secondView];
    [self.view addSubview:_thirdView];
}

- (void)viewDidAppear:(BOOL)animated {
    [_secondView becomeFirstResponder];
}

- (void)updateViewConstraints {
    [_firstView autoSetDimensionsToSize:CGSizeMake(100, 100)];
    [_secondView autoSetDimensionsToSize:CGSizeMake(200, 200)];
    [_thirdView autoSetDimensionsToSize:CGSizeMake(300, 300)];
    
    [_firstView autoCenterInSuperview];
    [_secondView autoCenterInSuperview];
    [_thirdView autoCenterInSuperview];
    
    [super updateViewConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            NSLog(@"ViewController:Play");
            break;
            
        default:
            break;
    }
}
@end
