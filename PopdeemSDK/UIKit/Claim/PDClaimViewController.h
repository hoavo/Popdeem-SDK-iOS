//
//  PDClaimViewController.h
//  PopdeemSDK
//
//  Created by Niall Quinn on 26/11/2015.
//  Copyright © 2015 Popdeem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PD_SZTextView.h"
#import "PDReward.h"

@class PDClaimViewModel;

@interface PDClaimViewController : UIViewController

@property (nonatomic, strong) PDClaimViewModel *viewModel;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *rewardInfoView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *controlButtonsView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *withLabelView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *claimButtonView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *facebookButtonView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *twitterButtonView;
@property (unsafe_unretained, nonatomic) IBOutlet PD_SZTextView *textView;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *rewardDescriptionLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *rewardInfoLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *rewardRulesLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *rewardImageView;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *withLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *twitterForcedTagLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *twitterCharacterCountLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *facebookButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *twitterButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *keyboardHiderView;

- (id) initWithMediaTypes:(NSArray*)mediaTypes andReward:(PDReward*)reward;
- (void) renderView;

@end
