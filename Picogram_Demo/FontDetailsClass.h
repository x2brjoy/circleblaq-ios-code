//
//  FontDetailsClass.h
//  Picogram
//
//  Created by Rahul Sharma on 7/28/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#ifndef FontDetailsClass_h
#define FontDetailsClass_h

//Roboto family

#define RobotoRegular                                  @"Roboto-Regular"
#define RobotoMedium                                   @"Roboto-Medium"
#define RobotoThin                                     @"Roboto-Thin"
#define RobotoLight                                    @"Roboto-Light"
#define RobotoBold                                     @"Roboto-Bold"
#define LatoReg                                        @"Lato-Regular"


//AvenirNext family

#define AvenirNextCondensedRegular @"AvenirNextCondensed-Regular"
#define AvenirNextCondensedMediumItalic @"AvenirNextCondensed-MediumItalic"
#define AvenirNextCondensedUltraLightItalic @"AvenirNextCondensed-UltraLightItalic"
#define AvenirNextCondensedUltraLight @"AvenirNextCondensed-UltraLight"
#define AvenirNextCondensedBoldItalic @"AvenirNextCondensed-BoldItalic"
#define AvenirNextCondensedItalic @"AvenirNextCondensed-Italic"
#define AvenirNextCondensedMedium @"AvenirNextCondensed-Medium"
#define AvenirNextCondensedHeavyItalic @"AvenirNextCondensed-HeavyItalic"
#define AvenirNextCondensedHeavy @"AvenirNextCondensed-Heavy"
#define AvenirNextCondensedDemiBoldItalic @"AvenirNextCondensed-DemiBoldItalic"
#define AvenirNextCondensedDemiBold @"AvenirNextCondensed-DemiBold"
#define AvenirNextCondensedBold @"AvenirNextCondensed-Bold"


//avenir family.

#define AvenirBook                                     @"Avenir-Book"
#define AvenirHeavy                                    @"Avenir-Heavy"
#define AvenirOblique                                  @"Avenir-Oblique"
#define AvenirBlack                                    @"Avenir-Black"
#define AvenirBlackOblique                             @"Avenir-BlackOblique"
#define AvenirHeavyOblique                             @"Avenir-HeavyOblique"
#define AvenirLight                                    @"Avenir-Light"
#define AvenirMediumOblique                            @"Avenir-MediumOblique"
#define AvenirMedium                                   @"Avenir-Medium"
#define AvenirLightOblique                             @"Avenir-LightOblique"
#define AvenirRoman                                    @"Avenir-Roman"
#define AvenirBookOblique                              @"Avenir-BookOblique"
#endif

//method for finding  available font details in the project.

//-(void)fontFamily {
//    NSArray *fontFamilies = [UIFont familyNames];
//
//    for (int i = 0; i < [fontFamilies count]; i++)
//    {
//        NSString *fontFamily = [fontFamilies objectAtIndex:i];
//        NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
//        NSLog (@"%@: %@", fontFamily, fontNames);
//    }
//}
