//
//  InstagramAPIManager.swift
//  LocationHashtag
//
//  Created by High Jumper on 7/3/16.
//
//

import UIKit
import Alamofire

class InstagramLocationAPIManager: NSObject {
    
    static let sharedInstance = InstagramLocationAPIManager()
    
    
    let clientId = "3bff7a6a480f45da884f0642f2a9a0b5"
    let clientKey = "eea75409d3624f5087c9476a985fcb24"
    let accessToken = "2125776912.3bff7a6.49b185ab4d1c49149099d576880f1f30"
    let API_URL = "https://api.instagram.com/v1/locations/"
    
    typealias getLocationIDSuccessed = ((locations: [JSON]) -> Void)
    typealias getLocationInfoSuccessed = ((locationInfo : LocationModel) -> Void)
    typealias instagramfailedHandler = ( (error: NSError?) -> Void)

    override init() {
        super.init()
    }
    func getLocationId(lat : Double, lng : Double, successHandler :getLocationIDSuccessed, failedHandler : instagramfailedHandler){
        let params : [String : AnyObject] = [
                    "lat" : lat,
                    "lng" : lng,
                    "access_token" : accessToken,
                    "distance" : 20]
        Alamofire.request(.GET, "\(API_URL)search", parameters: params).validate(statusCode: 200..<300)
        .responseJSON { response in
            switch response.result {
            case .Success:
                debugPrint("GetLocationId : Success")
                let json = JSON(data : response.data!)
                let locations = json["data"].array
                debugPrint(locations)
                successHandler(locations: locations!)
                break
            case .Failure(let error):
                debugPrint("GetLocationId : Failed : \(error.description)")
                failedHandler(error: error)
                break
            }
        }
    }
    
//    func getLocaionInfo(locationId : String, successHandler: getLocationInfoSuccessed, failedHandler : instagramfailedHandler){
//        let params : [String : AnyObject] = [
//            "access_token" : accessToken
//        ]
//        Alamofire.request(.GET, "\(API_URL)\(locationId)", parameters: params)
//            .validate(statusCode: 200..<300)
//            .responseJSON { response in
//                switch response.result {
//                case .Success:
//                    debugPrint("GetLocationInfo : Success")
//                    let json = JSON(data : response.data!)
//                    debugPrint(json)
////                    successHandler(locationInfo: )
//                    break
//                case .Failure(let error):
//                    debugPrint("GetLocationInfo : Failed : \(error.description)")
////                    failedHandler(error: error)
//                    break
//                }
//        }
//    }
    
    func getLocationMediaRecent(locationId : String, successHandler: getLocationIDSuccessed, failedHandler : instagramfailedHandler){
        let params : [String : AnyObject] = [
            "access_token" : accessToken
        ]
        Alamofire.request(.GET, "\(API_URL)\(locationId)/media/recent", parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .Success:
                    debugPrint("GetLocationMediaRecent : Success")
                    let json = JSON(data : response.data!)
                    debugPrint(json)
                    successHandler(locations: json["data"].array!)
                    break
                case .Failure(let error):
                    debugPrint("GetLocationMediaRecent : Failed : \(error.description)")
                    failedHandler(error: error)
                    break
                }
        }
    }
    
}
