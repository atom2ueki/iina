//
//  Model.m
//  yeelight_local_mac_demo
//
//  Created by Tony Peng on 16/6/5.
//  Copyright © 2016年 Tony Peng. All rights reserved.
//

#import "Socket.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"

NSString *const kHost = @"239.255.255.250";
static const int kPort = 1982;

@interface Socket()<GCDAsyncUdpSocketDelegate,GCDAsyncSocketDelegate>
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) GCDAsyncSocket *tcpSocket1;
@property (strong, nonatomic) GCDAsyncSocket *tcpSocket2;
@property (strong, nonatomic) NSMutableDictionary *devices;
@property (assign, nonatomic) NSInteger msgId1;
@property (assign, nonatomic) NSInteger msgId2;
@end
@implementation Socket

+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype)initInstance {
    self = [super init];
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.tcpSocket1 = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.tcpSocket2 = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.msgId1 = 1;
    self.msgId2 = 1;
    return self;
}

- (void)p_setupSocket{
    NSError *error = nil;
    if (![self.udpSocket bindToPort:kPort error:&error]){
        NSLog(@"Error binding to port: %@", error);
        return;
    }
    if(![self.udpSocket joinMulticastGroup:kHost error:&error]){
        NSLog(@"Error connecting to multicast group: %@", error);
        return;
    }
    if (![self.udpSocket beginReceiving:&error]){
        NSLog(@"Error receiving: %@", error);
        return;
    }
}

- (void)searchDevice{
    [self p_setupSocket];
    NSString *str = @"M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1982\r\nMAN: \"ssdp:discover\"\r\nST: wifi_bulb";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:data toHost:kHost port:kPort withTimeout:3 tag:0];
}

- (BOOL)connect:(Device *)device{

    if (device.did == 249961148) {
        // lamp15
        NSError *err = nil;
        BOOL connected = [self.tcpSocket1 connectToHost:device.host onPort:device.port error:&err];
        if (!connected) {
            NSLog(@"connect fail with err %@",err);
        }
        return connected;
    }else if (device.did == 53719936) {
        // strip
        NSError *err = nil;
        BOOL connected = [self.tcpSocket2 connectToHost:device.host onPort:device.port error:&err];
        if (!connected) {
            NSLog(@"connect fail with err %@",err);
        }
        return connected;
    }else {
        return NO;
    }
}

- (void)disconnect:(int)did {
    if (did == 249961148) {
        [self.tcpSocket1 disconnect];
    }else if (did == 53719936) {
        [self.tcpSocket2 disconnect];
    }
}

- (void)disconnectAll {
    [self.tcpSocket1 disconnect];
    [self.tcpSocket2 disconnect];
}

- (void)sendDataToDevice:(NSMutableDictionary *)data did:(int)did{
    if (did == 249961148) {
        // lamp15
        [data setObject:@(self.msgId1) forKey:@"id"];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *str = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] stringByAppendingString:@"\r\n"];
        NSData *cmd = [str dataUsingEncoding:NSUTF8StringEncoding];
        [self.tcpSocket1 writeData:cmd withTimeout:3 tag:0];
        self.msgId1++;
    }else if (did == 53719936) {
        // stripe
        [data setObject:@(self.msgId2) forKey:@"id"];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *str = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] stringByAppendingString:@"\r\n"];
        NSData *cmd = [str dataUsingEncoding:NSUTF8StringEncoding];
        [self.tcpSocket2 writeData:cmd withTimeout:3 tag:0];
        self.msgId2++;
    }
}

- (NSDictionary *)getDevices{
    return [self.devices copy];
}

// GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"receive data %@",str);
    //Filter yeelight device
    if ([str containsString:@"id"] && [str containsString:@"yeelight://"] && [str containsString:@"model"]) {
        Device *device = [[Device alloc] init];
        NSDictionary *dic = [self p_formartResponse:str];
        device.did = [self p_hexStr2int:dic[@"id"]];
        device.location = [dic[@"Location"] stringByReplacingOccurrencesOfString:@"yeelight://" withString:@""];
        device.model = dic[@"model"];
        device.isOn = [dic[@"power"] isEqualToString:@"on"] ? YES : NO;
        if (!self.devices) {
            self.devices = [[NSMutableDictionary alloc] init];
        }
        [self.devices setObject:device forKey:[NSNumber numberWithInt:device.did]];
    }else {
//        NSLog(@"%@", str);
        NSDictionary *dic = [self p_formartResponse:str];
        NSLog(@"receive location %@", [dic[@"Location"] stringByReplacingOccurrencesOfString:@"yeelight://" withString:@""]);
    }
}

// GCDAsyncSocketDelegate TCp

- (NSDictionary *)p_formartResponse:(NSString *)str{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSArray *arr = [str componentsSeparatedByString:@"\r\n"];
    for (NSString *s in arr) {
        if ([s containsString:@": "]) {
            NSArray *tmp = [s componentsSeparatedByString:@": "];
            [dic setObject:tmp[1] forKey:tmp[0]];
        }
    }
//    NSLog(@"dic %@",dic);
    return [dic copy];
}

- (int)p_hexStr2int:(NSString *)str{
    unsigned int outVal;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner scanHexInt:&outVal];
    return outVal;
}

@end
