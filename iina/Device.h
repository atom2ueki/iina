//
//  Device.h
//  yeelight_local_mac_demo
//
//  Created by Tony Peng on 16/6/5.
//  Copyright © 2016年 Tony Peng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface Device : NSObject
@property(assign, nonatomic)int did;
@property(strong, nonatomic)NSString *location;
@property(strong, nonatomic)NSString *model;
@property(strong, nonatomic)NSString *host;
@property(assign, nonatomic)NSInteger port;
@property(assign, nonatomic)BOOL isOn;
- (BOOL)connect;
- (void)disconnect;
- (void)swichtLight:(BOOL)isOn;
- (void)changeBrightness:(NSInteger)bright;
- (void)changeColor:(NSColor*)hue;
- (void)changeBgColor:(NSColor*)hue;
- (void)changeRGB:(NSInteger)rgb;
- (void)switchMoonMode:(BOOL)isOn;
- (void)startFlow;
- (void)adjustBrightness:(NSInteger)brightness;
- (void)adjustBgBrightness:(NSInteger)brightness;
- (void)changeCT:(NSInteger)ct;
@end
