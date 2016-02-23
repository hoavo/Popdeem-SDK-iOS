//
//  FeedCell.h
//  Popdeem
//
//  Created by Niall Quinn on 06/07/2015.
//  Copyright (c) 2015 Niall Quinn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFeedItem.h"
@interface FeedCell : UITableViewCell

@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *label;

- (id) initWithFrame:(CGRect)frame forFeedItem:(PDFeedItem*)feedItem;
- (NSString*) timeStringForItem:(PDFeedItem*)item;
- (NSAttributedString*) stringForItem:(PDFeedItem*)feedItem;

@end