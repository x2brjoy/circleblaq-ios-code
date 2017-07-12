//
//  ContacDataBase.h
//  Sup
//
//  Created by Rahul Sharma on 7/7/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContacDataBase : NSObject


+(instancetype)sharedInstance;

@property (strong,nonatomic) NSDictionary *contacPropertydict;


-(void)getDocumentInfoForID:(NSString *)docID;
-(NSArray *)getDataContacDataFromDB;

-(void)saveDataInDocument:(NSString *)documentID withMessages:(NSMutableArray *)messages;
-(void)deleteAllContacDataFromDB;


-(void)updateContacDatabase:(NSDictionary *)dict contacID:(NSString*)contcID;


-(NSArray*)updateContacDBtoRemove:(NSDictionary*)dict contacID:(NSString*)contacID;
-(void)deleteObjectFromDB:(NSDictionary *)dict contacID:(NSString *)contcID;

-(NSArray*)deleteObjectFromDBtoRemove:(NSDictionary*)dict contacID:(NSString *)contcID;
@end
