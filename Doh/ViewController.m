//
//  ViewController.m
//  Doh
//
//  Created by yangsen on 2021/7/15.
//
#import "QNDoh.h"
#import "QNDnsServer.h"
#import "NSData+QNRW.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    NSMutableData *data = [NSMutableData data];
    
    [data qn_appendBigEndianInt16:0xED];
    [data qn_appendLittleEndianInt16:0xED];
    [data qn_appendBigEndianSInt16:0xED];
    [data qn_appendLittleEndianSInt16:0xED];
    NSLog(@"%@",data);
    
    NSLog(@"0: %x",[data qn_readBigEndianInt16:0]);
    NSLog(@"1: %x",[data qn_readLittleEndianInt16:2]);
    NSLog(@"2: %x",[data qn_readBigEndianSInt16:4]);
    NSLog(@"3: %x",[data qn_readLittleEndianSInt16:6]);
    
    NSError *error = nil;
    NSString *server = @"https://dns.cloudflare.com/dns-query";
//    QNDoh *doh = [QNDoh doh:server timeout:3];
//
//    NSString *host = @"www.baidu.com";
//    int typeArray[6] = {1, 2, 5, 6, 16, 28};
//    for (int i=0; i<6; i++) {
//        QNDnsResponse *response = [doh lookupHost:host recordType:typeArray[i] error:&error];
//        NSLog(@"response:%@ error:%@", response, error);
//    }
    
    server = @"114.114.114.114";
    NSString *host = @"en.wikipedia.org";
    QNDnsServer *dnsServer = [QNDnsServer dnsServer:server timeout:30];
    QNDnsResponse *response = [dnsServer lookupHost:host recordType:QNDnsRecordTypeAAAA error:&error];
    NSLog(@"response:%@ error:%@", response, error);
    
//    int typeArray[6] = {1, 2, 5, 6, 16, 28};
//    for (int i=0; i<6; i++) {
//        QNDnsResponse *response = [dnsServer lookupHost:host recordType:typeArray[i] error:&error];
//        NSLog(@"response:%@ error:%@", response, error);
//    }
    
}
@end
