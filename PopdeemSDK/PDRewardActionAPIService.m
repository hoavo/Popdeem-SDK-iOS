//
//  PDRewardActionAPIService.m
//  PopdeemSDK
//
//  Created by Niall Quinn on 04/11/2015.
//  Copyright © 2015 Popdeem. All rights reserved.
//

#import "PDRewardActionAPIService.h"
#import "PDUser.h"
#import "PDReward.h"
#import "PDRewardStore.h"
#import "PDUser+Facebook.h"
#import "PDWallet.h"

@implementation PDRewardActionAPIService

-(id) init {
    if (self = [super init]) {
        return self;
    }
    return nil;
}

- (void) claimReward:(NSInteger)rewardId
            location:(PDLocation*)location
         withMessage:(NSString*)message
       taggedFriends:(NSArray*)taggedFriends
               image:(UIImage*)image
            facebook:(BOOL)facebook
             twitter:(BOOL)twitter
          completion:(void (^)(NSError *error))completion {
    
    NSURLSession *session = [NSURLSession createPopdeemSession];
    NSString *path = [NSString stringWithFormat:@"%@,%@/%ld/claim",self.baseUrl,REWARDS_PATH,(long)rewardId];
    
    PDUser *user = [PDUser sharedInstance];
    PDReward *r = [PDRewardStore find:rewardId];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //Add the message
    if (message) {
        [params setObject:message forKey:@"message"];
    }
    //Add the image. If no image, make sure it is allowed to post
    if (image) {
        NSString *imageString = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:0];
        [params setObject:imageString forKey:@"file"];
    } else if (r.action == PDRewardActionPhoto) {
        //There must be a photo on this action
        NSLog(@"The reward action specifies PDRewardActionPhoto, but there is no image attached. Cannot claim this reward...Aborting");
        NSDictionary *userDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"The reward action specifies PDRewardActionPhoto, but there is no image attached. Cannot claim this reward...", NSLocalizedDescriptionKey,
                                        nil];
        NSError *endError = [[NSError alloc] initWithDomain:kPopdeemErrorDomain
                                                       code:PDErrorCodeClaimFailed
                                                   userInfo:userDictionary];
        completion(endError);
        return;
    }
    
    //Facebook and Twitter credentials
    if (facebook) {
        NSMutableDictionary *facebookParams = [NSMutableDictionary dictionary];
        [facebookParams setObject:user.facebookParams.accessToken forKey:@"access_token"];
        if (taggedFriends.count > 0) {
            [facebookParams setObject:user.selectedFriendsJSONRepresentation  forKey:@"associated_account_ids"];
        }
        [params setObject:facebookParams forKey:@"facebook"];
    }
    if (twitter) {
        NSMutableDictionary *twitterParams = [NSMutableDictionary dictionary];
        [twitterParams setObject:user.twitterParams.accessToken forKey:@"access_token"];
        [twitterParams setObject:user.twitterParams.accessSecret forKey:@"access_secret"];
        [params setObject:twitterParams forKey:@"twitter"];
    }
    
    //user location
    NSDictionary *locationParams = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%.4f",location.geoLocation.latitude],@"latitude",
                                    [NSString stringWithFormat:@"%.4f",location.geoLocation.longitude], @"longitude",
                                    [NSString stringWithFormat:@"%ld", (long)location.identifier], @"id",
                                    nil];
    [params setObject:locationParams forKey:@"location"];
    
    [session POST:path params:params completion:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
            return;
        }
        [PDRewardStore deleteReward:rewardId];
        [session invalidateAndCancel];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
    }];
}

- (void) redeemReward:(NSInteger)rewardId
           completion:(void (^)(NSError *error))completion {
    
    NSURLSession *session = [NSURLSession createPopdeemSession];
    NSString *path = [NSString stringWithFormat:@"%@/%@/%ld/redeem",self.baseUrl,REWARDS_PATH,(long)rewardId];
    PDReward *r = [PDWallet find:rewardId];
    if (r.type == PDRewardTypeSweepstake) {
        NSDictionary *userDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Cannot redeem a sweepstake reward", NSLocalizedDescriptionKey,
                                        nil];
        NSError *endError = [[NSError alloc] initWithDomain:kPopdeemErrorDomain
                                                       code:PDErrorCodeRedeemFailed
                                                   userInfo:userDictionary];
        completion(endError);
    }
    
    PDUser *_user = [PDUser sharedInstance];
    
    [session POST:path params:nil completion:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
            return;
        }
        [PDWallet remove:rewardId];
        [session invalidateAndCancel];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
    }];
}
@end