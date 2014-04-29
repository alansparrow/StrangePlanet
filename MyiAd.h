//
//  MyiAd.h
//  IncredibleEgg
//
//  Created by Alan Sparrow on 4/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import "iAd/ADBannerView.h"

@interface MyiAd : NSObject<ADBannerViewDelegate>
{
    ADBannerView *_adBannerView;
    bool _adBannerViewIsVisible;
    UIView *_contentView;
    bool mIsLoaded;
}
@property (nonatomic) bool adBannerViewIsVisible;

-(void)showBannerView;
-(void)RemoveiAd ;
- (void)createAdBannerView ;
-(void)hideBannerView;

@end