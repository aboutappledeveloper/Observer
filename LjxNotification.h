//
//  ViewController.h
//  NS
//
//  Created by lvjianxiong on 2019/6/3.
//  Copyright © 2019 cn.lvjianxiong. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 
 */
@interface LjxNotification : NSObject<NSCopying,NSCoding>

@property (readonly, copy) NSString * _Nonnull name;
@property (nullable, readonly, retain) id object;
@property (nullable, readonly, copy) NSDictionary *userInfo;

- (nullable instancetype)initWithName:(NSString * _Nonnull)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo;
- (nullable instancetype)initWithCoder:(NSCoder *_Nonnull)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@interface LjxNotificationCenter : NSObject

+ (instancetype _Nonnull )defaultCenter;

- (void)addObserver:(id _Nonnull )observer selector:(SEL _Nonnull )aSelector name:(nullable NSString *)aName object:(nullable id)anObject;

- (id <NSObject>_Nonnull)addObserverForName:(NSString * _Nonnull)name object:(nullable id)obj queue:(nullable NSOperationQueue *)queue usingBlock:(void (^_Nullable)(LjxNotification * _Nonnull note))block;

- (void)postNotification:(LjxNotification *_Nonnull)notification;

- (void)postNotificationName:(NSString * _Nonnull)aName object:(nullable id)anObject;

- (void)postNotificationName:(NSString * _Nonnull)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

- (void)removeObserver:(id _Nonnull )observer;

- (void)removeObserver:(id _Nonnull )observer name:(nullable NSString *)aName object:(nullable id)anObject;
@end
