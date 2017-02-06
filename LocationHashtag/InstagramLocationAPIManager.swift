//
//  InstagramAPIManager.swift
//  LocationHashtag
//
//  Created by High Jumper on 7/3/16.
//
//

import UIKit
import Alamofire

class InstagramAPIManager: NSObject {
    
    static let sharedInstance = InstagramAPIManager()
    
    let clientId = "3bff7a6a480f45da884f0642f2a9a0b5"
    let clientKey = "eea75409d3624f5087c9476a985fcb24"
    let redirectURI = "ig3bff7a6a480f45da884f0642f2a9a0b5://authorize"
    let redirectURI1 = "http://www.hashbarapp.com"
    let accessToken = "2125776912.3bff7a6.49b185ab4d1c49149099d576880f1f30"
    
    typealias getLocationIDSuccessed = ((locations: [JSON]) -> Void)
    typealias getLocationInfoSuccessed = ((locationInfo : LocationModel) -> Void)
    typealias instagramfailedHandler = ( (error: NSError?) -> Void)
//    typealias getGeocodeSuccessed = ((locationName: String) -> Void)

//    var accessToken : String?
    override init() {
        super.init()
    }
    
//    func authorization(){
//        let params  = ["client_id": clientId,
//                       "redirect_uri" : redirectURI1,
//                       "response_type": "token"]
//       Alamofire.request(.GET, "https://instagram.com/oauth/authorize", parameters: params )
//        .validate(statusCode: 200..<300)
//        .responseJSON { response in
//            switch response.result {
//            case .Success:
//                debugPrint(response.data)
//                let json = JSON(data : response.data!)
//                break
//            case .Failure(let error):
//                debugPrint(error)
//                break
//            }
//        }
//    }
    func getLocationId(lat : Double, lng : Double, successHandler :getLocationIDSuccessed, failedHandler : instagramfailedHandler){
        let params : [String : AnyObject] = [
                    "lat" : lat,
                    "lng" : lng,
                    "access_token" : accessToken]
        Alamofire.request(.GET, "https://api.instagram.com/v1/locations/search", parameters: params).validate(statusCode: 200..<300)
        .responseJSON { response in
            switch response.result {
            case .Success:
                debugPrint("GetLocationId : Success")
                let json = JSON(data : response.data!)
                let locations = json["data"].array
                successHandler(locations: locations!)
                break
            case .Failure(let error):
                debugPrint("GetLocationId : Failed : \(error.description)")
                failedHandler(error: error)
                break
            }
        }
    }
    
    func getLocaionInfo(locationId : String, successHandler: getLocationInfoSuccessed, failedHandler : instagramfailedHandler){
        
        let params : [String : AnyObject] = [
            
        ]
    }
    
}
