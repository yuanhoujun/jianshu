//
//  ThirdView.m
//  EventDelivery
//
//  Created by scott on 15/9/15.
//  Copyright © 2015年 xbdx. All rights reserved.
//

#import "ThirdView.h"

@implementation ThirdView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"ThirdView:touchesBegan");
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            NSLog(@"ThirdView:Play");
            break;
            
        default:
            break;
    }
}

@end
