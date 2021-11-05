//
//  Device.m
//  yeelight_local_mac_demo
//
//  Created by Tony Peng on 16/6/5.
//  Copyright © 2016年 Tony Peng. All rights reserved.
//

#import "Device.h"
#import "Socket.h"
@interface Device()
@end

@implementation Device

- (BOOL)connect{
    return [[Socket sharedInstance] connect:self];
}

- (void)disconnect{
    [[Socket sharedInstance] disconnect: self.did];
}

- (void)swichtLight:(BOOL)isOn{
    NSString *power = @"off";
    if (isOn) {
        power = @"on";
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"set_power" forKey:@"method"];
//    [dic setObject:@[power, @"smooth", @500, @(5)] forKey:@"params"];
    [dic setObject:@[power, @"smooth", @500] forKey:@"params"];
    [[Socket sharedInstance] sendDataToDevice:dic did: self.did];
}

- (void)changeBrightness:(NSInteger)bright{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"set_bright" forKey:@"method"];
    [dic setObject:@[@(bright), @"smooth", @500] forKey:@"params"];
    [[Socket sharedInstance] sendDataToDevice:dic did: self.did];
}

- (void)changeColor:(NSColor*)hue{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"set_hsv" forKey:@"method"];
    [dic setObject:@[@(hue.hueComponent*359), @(hue.saturationComponent*100), @"smooth", @500] forKey:@"params"];
    [[Socket sharedInstance] sendDataToDevice:dic did: self.did];
}

- (void)changeBgColor:(NSColor*)hue{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"bg_set_hsv" forKey:@"method"];
    [dic setObject:@[@(hue.hueComponent*359), @(hue.saturationComponent*100), @"smooth", @500] forKey:@"params"];
    [[Socket sharedInstance] sendDataToDevice:dic did: self.did];
}

- (void)changeCT:(NSInteger)ct{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"set_ct_abx" forKey:@"method"];
    [dic setObject:@[@(ct),@"smooth", @500] forKey:@"params"];
    [[Socket sharedInstance] sendDataToDevice:dic did: self.did];
}

- (void)switchMoonMode:(BOOL)isOn{
    NSString *moonMode = @"1";
    if (isOn) {
        moonMode = @"0";
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"active_mode" forKey:@"method"];
    [dic setObject:@[moonMode, @"smooth", @500] forKey:@"params"];
    [[Socket sharedInstance] sendDataToDevice:dic did: self.did];
}

- (void)changeRGB:(NSInteger)rgb{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"bg_set_rgb" forKey:@"method"];
    [dic setObject:@[@(rgb),@"smooth", @300] forKey:@"params"];
    [[Socket sharedInstance] sendDataToDevice:dic did: self.did];
}

- (void)startFlow{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"bg_start_cf" forKey:@"method"];
    [dic setObject:@[@(10),@(0), @"1000, 2, 2700, 100, 500, 1, 255, 10, 5000, 7, 0,0, 500, 2, 5000, 1"] forKey:@"params"];
    [[Socket sharedInstance] sendDataToDevice:dic did: self.did];
}

- (void)adjustBrightness:(NSInteger)brightness {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"adjust_bright" forKey:@"method"];
    [dic setObject:@[@(brightness), @200] forKey:@"params"];
    [[Socket sharedInstance] sendDataToDevice:dic did: self.did];
}

- (void)adjustBgBrightness:(NSInteger)brightness {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"bg_adjust_bright" forKey:@"method"];
    [dic setObject:@[@(brightness), @200] forKey:@"params"];
    [[Socket sharedInstance] sendDataToDevice:dic did: self.did];
}

- (void)setLocation:(NSString *)location{
    _location = location;
    NSArray *arr = [location componentsSeparatedByString:@":"];
    self.host = arr[0];
    self.port = [arr[1] integerValue];
}

@end
