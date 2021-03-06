//
//  QNDnsServer.m
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import "QNDnsServer.h"
#import <GCDAsyncUdpSocket.h>

@interface QNDnsFlow : NSObject

@property(nonatomic, assign)long flowId;
@property(nonatomic, strong)QNDnsRequest *dnsRequest;
@property(nonatomic, strong)GCDAsyncUdpSocket *socket;
@property(nonatomic,   copy)void(^complete)(QNDnsResponse *response, NSError *error);

@end
@implementation QNDnsFlow
@end

#define kMinPort 10000
#define kMaxPort (0xFFFF)
#define kDnsPort 53
#define kGetPortMaxTime 10
@interface QNDnsServer()<GCDAsyncUdpSocketDelegate>

@property(nonatomic, strong)dispatch_queue_t queue;
@property(nonatomic, assign)int timeout;
@property(nonatomic,   copy)NSString *server;
@property(nonatomic, strong)NSMutableDictionary *flows;

@end
@implementation QNDnsServer

+ (instancetype)dnsServer:(NSString *)server timeout:(int)timeout {
    QNDnsServer *dnsServer = [[QNDnsServer alloc] init];
    dnsServer.server = server;
    dnsServer.timeout = timeout;
    dnsServer.flows = [NSMutableDictionary dictionary];
    dnsServer.queue = dispatch_queue_create("com.qiniu.dns.server.queue", DISPATCH_QUEUE_CONCURRENT);
    return dnsServer;
}

- (QNDnsResponse *)lookupHost:(NSString *)host
                   recordType:(QNDnsRecordType)recordType
                        error:(NSError *__autoreleasing  _Nullable *)error {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSError *errorP = nil;
    __block QNDnsResponse *dnsResponse = nil;
    [self request:host recordType:recordType complete:^(QNDnsResponse *response, NSError *err) {
        errorP = err;
        dnsResponse = response;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, self.timeout * NSEC_PER_SEC));
    
    if (error != NULL) {
        *error = errorP;
    }
    
    return dnsResponse;
}

- (void)request:(NSString *)host
     recordType:(QNDnsRecordType)recordType
       complete:(void(^)(QNDnsResponse *response, NSError *error))complete {
    if (complete == nil) {
        return;
    }
    
    int messageId = arc4random()%(0xFFFF);
    QNDnsRequest *dnsRequest = [QNDnsRequest request:messageId recordType:recordType host:host];
    
    NSError *error = nil;
    NSData *requestData = [dnsRequest toDnsQuestionData:&error];
    if (error) {
        complete(nil, error);
        return;
    }
    
    GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.queue];
    int time = 0;
    while (time < kGetPortMaxTime) {
        [socket bindToPort:[self refreshPort] error: &error];
        if (!error) {
            break;
        }
        error = nil;
        time++;
    }
    if (error) {
        complete(nil, error);
        return;
    }
    
    [socket beginReceiving:&error];
    if (error) {
        complete(nil, error);
        return;
    }
    
    QNDnsFlow *flow = [[QNDnsFlow alloc] init];
    flow.dnsRequest = dnsRequest;
    flow.socket = socket;
    flow.flowId = [socket hash];
    flow.complete = complete;
    [self setFlow:flow withId:flow.flowId];
    
    [socket sendData:requestData toHost:self.server port:kDnsPort withTimeout:self.timeout tag:flow.flowId];
}

- (void)udpSocketComplete:(GCDAsyncUdpSocket *)sock data:(NSData *)data error:(NSError * _Nullable)error {
    [sock close];
    
    QNDnsFlow *flow = [self getFlowWithId:[sock hash]];
    if (!flow) {
        return;
    }
    [self removeFlowWithId:flow.flowId];
    
    if (error != nil) {
        flow.complete(nil, error);
    } else if (data != nil) {
        NSError *err = nil;
        QNDnsResponse *response = [QNDnsResponse dnsResponse:flow.dnsRequest dnsRecordData:data error:&err];
        flow.complete(response, err);
    } else {
        flow.complete(nil, nil);
    }
}

//MARK: -- GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error {
    [self udpSocketComplete:sock data:nil error:error];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error {
    [self udpSocketComplete:sock data:nil error:error];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext {
    [self udpSocketComplete:sock data:data error:nil];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error {
    [self udpSocketComplete:sock data:nil error:error];
}


//MARK: flows
- (QNDnsFlow *)getFlowWithId:(long)flowId {
    NSString *key = [NSString stringWithFormat:@"%ld", flowId];
    QNDnsFlow *flow = nil;
    @synchronized (self) {
        flow = self.flows[key];
    }
    return flow;
}

- (BOOL)setFlow:(QNDnsFlow *)flow withId:(long)flowId {
    if (flow == nil) {
        return false;
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld", flowId];
    @synchronized (self) {
        self.flows[key] = flow;
    }
    return true;
}

- (void)removeFlowWithId:(long)flowId {
    NSString *key = [NSString stringWithFormat:@"%ld", flowId];
    @synchronized (self) {
        [self.flows removeObjectForKey:key];
    }
}

- (long)refreshPort {
    return arc4random()%(kMaxPort + kMinPort) - kMinPort;
}

@end
