//
//  FirstView.m
//  EventDelivery
//
//  Created by scott on 15/9/15.
//  Copyright © 2015年 xbdx. All rights reserved.
//

#import "FirstView.h"

@implementation FirstView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"FirstView:touchesBegan");
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            NSLog(@"FirstView:Play");
            break;
            
        default:
            break;
    }
}

@end
