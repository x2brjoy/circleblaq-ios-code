//
//  FavDataBase.h
//  Sup
//
//  Created by Rahul Sharma on 7/7/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavDataBase : NSObject

+(instancetype)sharedInstance;

@property (strong,nonatomic) NSDictionary *favPropertydict;

-(void)getDocumentInfoForID:(NSString *)docID;
-(NSArray *)getDataFavDataFromDB;


-(void)saveDataInDocument:(NSString *)documentID withMessages:(NSMutableArray *)messages;
-(void)updateContacDatabase:(NSDictionary *)dict contacID:(NSString*)contcID;

-(void)deleteObjectFromDB:(NSDictionary *)dict favID:(NSString *)favID;

@end
