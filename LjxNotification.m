//
//  ViewController.m
//  NS
//
//  Created by lvjianxiong on 2019/6/3.
//  Copyright © 2019 cn.lvjianxiong. All rights reserved.
//

#import "LjxNotification.h"


/**
 NotificationModel 观察者模型
 通知涉及的参数
 */
@interface LjxNotificationModel : NSObject
@property (nonatomic , strong) id _Nonnull observer;//观察者
@property (nonatomic , copy) NSString * _Nonnull name;//通知名称
@property (nonatomic , strong) id _Nonnull object;//通知对象
@property (nonatomic , assign) SEL _Nonnull selector;//执行的方法
@property (nonatomic , strong) NSOperationQueue * _Nullable operationQueue;//队列
@property (nonatomic , copy) void(^block)(LjxNotification *notification);//回调


@end

@implementation LjxNotificationModel


@end




/**
 通知对象
 */
@interface LjxNotification ()

@property (copy) NSString *name;
@property (retain) id object;
@property (copy) NSDictionary *userInfo;

@end;

@implementation LjxNotification


/**
 初始化LjxNotification，并为属性赋值

 @param name 通知名称
 @param object 通知对象
 @param userInfo 参数
 @return LjxNotification
 */
- (nullable instancetype)initWithName:(NSString * _Nonnull)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo{
    LjxNotification *notification = [[LjxNotification alloc] init];
    notification.name = self.name;
    notification.object = self.object;
    notification.userInfo = self.userInfo;
    return notification;
}


/**
 实现NSCopying协议

 @param zone NSZone
 @return LjxNotification
 */
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    LjxNotification *notification = [[self class] allocWithZone:zone];
    notification.name = self.name;
    notification.object = self.object;
    notification.userInfo = self.userInfo;
    return notification;
}


/**
 encode编码

 @param aCoder NSCoder
 */
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_object forKey:@"object"];
    [aCoder encodeObject:_userInfo forKey:@"userInfo"];
}


/**
 decode解码

 @param aDecoder NSCoder
 @return LjxNotification
 */
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.object = [aDecoder decodeObjectForKey:@"object"];
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    }
    return self;
}

@end



/**
 通知中心
 */
@interface LjxNotificationCenter ()


/**
 首先，信息的传递就依靠通知(LjxNotification),也就是说，通知就是信息(执行的方法，观察者本身(self),参数)的包装。通知中心(LjxNotificationCenter)是个单例，向通知中心注册观察者，也就是说，这个通知中心有个集合，这个集合存放着观察者。那么这个集合是什么样的数据类型 ？ 可以这么思考： 发送通知需要name参数，添加观察者也有个name参数，这两个name一样的时候，当发送通知时候，观察者对象就能接受到信息，执行对应的操作。那么这个集合很容易想到就是NSDictionary!
 key就是name，value就是NSArray(存放数据模型)，里面存放观察者对象

 当发送通知时，在通知通知的字典，根据name找到value，这个value就是一数组，数组里面存放数据模型(observer、SEL)。即可执行对应的行为
 */
@property (nonatomic, strong) NSMutableDictionary *notificationDict;

@end

@implementation LjxNotificationCenter


/**
 单例

 @return LjxNotificationCenter
 */
+ (instancetype)defaultCenter{
    static LjxNotificationCenter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LjxNotificationCenter alloc] init];
    });
    return instance;
}


/**
 init，在init方法中初始化存放通知的数据结构NSMutableDictionary

 @return LjxNotificationCenter
 */
- (instancetype)init{
    self = [super init];
    if (self) {
        self.notificationDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}


/**
 向通知中心添加通知

 @param observer 观察者
 @param aSelector 执行方法
 @param aName 通知名称
 @param anObject 通知对象
 */
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject{
    NSMutableArray *observerArray = [self.notificationDict objectForKey:aName];
    LjxNotificationModel *model = [[LjxNotificationModel alloc] init];
    model.observer = observer;
    model.name = aName;
    model.selector = aSelector;
    
    if (observerArray && [observerArray count]>0) {
        [observerArray addObject:model];
    }else{
        observerArray = [[NSMutableArray alloc] init];
        [observerArray addObject:model];
    }
    [self.notificationDict setObject:observerArray forKey:aName];
}


/**
 向通知中心添加通知

 @param name 通知名称
 @param obj 通知对象
 @param queue 目标线程
 @param block 回调函数
 @return 观察者
 */
- (id <NSObject>_Nonnull)addObserverForName:(NSString * _Nonnull)name object:(nullable id)obj queue:(nullable NSOperationQueue *)queue usingBlock:(void (^_Nullable)(LjxNotification * _Nonnull note))block{
    NSObject *observer = [[NSObject alloc] init];
    NSMutableArray *observerArray = [self.notificationDict objectForKey:name];
    LjxNotificationModel *model = [[LjxNotificationModel alloc] init];
    model.name = name;
    model.operationQueue = queue;
    model.block = block;
    model.observer = observer;
    if (observerArray && [observerArray count]>0) {
        [observerArray addObject:model];
    }else{
        observerArray = [[NSMutableArray alloc] init];
        [observerArray addObject:model];
    }
    [self.notificationDict setObject:observerArray forKey:name];
    
    return observer;
}



/**
 通知中心向观察者发送消息
 注意：发送通知有三种方式，最终都是通过 - (void)postNotification:(LjxNotification *)notification 来发送
 @param notification 通知对象
 */
- (void)postNotification:(LjxNotification *)notification{
    NSArray *observerArray = [self.notificationDict objectForKey:notification.name];
    for (LjxNotificationModel *model in observerArray) {
        id observer = model.observer;
        SEL selector = model.selector;
        id object = model.object;
        if (model.block) {
            if (!model.operationQueue) {
                model.block(notification);
            }else{
                NSBlockOperation *blockOption = [NSBlockOperation blockOperationWithBlock:^{
                    model.block(notification);
                }];
                NSOperationQueue *curQueue = model.operationQueue;
                [curQueue addOperation:blockOption];
            }
        }else{
            [observer performSelector:selector withObject:object withObject:notification];
        }
    }
}


/**
 通知中心向观察者发送消息

 @param aName 通知名称
 @param anObject 通知对象
 */
- (void)postNotificationName:(NSString * _Nonnull)aName object:(nullable id)anObject{
    LjxNotification *notification = [[LjxNotification alloc] initWithName:aName object:anObject userInfo:nil];
    [self postNotification:notification];
}


/**
 通知中心向观察者发送消息

 @param aName 通知名称
 @param anObject 通知对象
 @param aUserInfo 参数
 */
- (void)postNotificationName:(NSString * _Nonnull)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo{
    LjxNotification *notification = [[LjxNotification alloc] initWithName:aName object:anObject userInfo:aUserInfo];
    [self postNotification:notification];
}


/**
 移除通知

 @param observer 观察者
 */
- (void)removeObserver:(id _Nonnull )observer{
    [self removeObserver:observer name:nil object:nil];
}


/**
 移除通知

 @param observer 观察者
 @param aName 通知名称
 @param anObject 通知对象
 */
- (void)removeObserver:(id)observer name:(nullable NSString *)aName object:(nullable id)anObject{
    NSMutableArray *observerArray = [self.notificationDict objectForKey:aName];
    [observerArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LjxNotificationModel *model = (LjxNotificationModel *)obj;
        if(!anObject || model.object==anObject){
            [observerArray removeObject:obj];
        }
    }];
}
@end
