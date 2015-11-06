//
//  PDWalletAPIService.m
//  PopdeemSDK
//
//  Created by Niall Quinn on 04/11/2015.
//  Copyright © 2015 Popdeem. All rights reserved.
//

#import "PDWalletAPIService.h"
#import "PDWallet.h"

@implementation PDWalletAPIService

-(id) init {
    if (self = [super init]) {
        return self;
    }
    return nil;
}

- (void) getRewardsInWalletWithCompletion:(void (^)(NSError *error))completion {
    
    NSURLSession *session = [NSURLSession createPopdeemSession];
    NSString *path = [NSString stringWithFormat:@"%@/%@",self.baseUrl,WALLET_PATH];
    [session GET:path params:nil completion:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
            return;
        }
        NSError *jsonError;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        [PDWallet removeAllRewards];
        for (NSDictionary *attributes in jsonObject) {
            PDReward *reward = [[PDReward alloc] initFromApi:attributes];
            if (reward.status == PDRewardStatusLive) {
                [PDWallet add:reward];
            }
        }
        [session invalidateAndCancel];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
    
    }];
}

@end