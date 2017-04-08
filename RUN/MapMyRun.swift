//
//  MapMyRun.swift
//  RUN
//
//  Created by Kurt Jensen on 4/7/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension Session {
    var mapMyRunHeaders: HTTPHeaders? {
        guard let accessToken = accessToken else { return nil }
        let headers: HTTPHeaders = ["Api-Key": Constants.MapMyRun.apiKey,
                                    "Authorization": "Bearer \(accessToken)"]
        return headers
    }
}

extension API {
    
    class MapMyRun {
        
        class func getToken(_ code: String, completion: @escaping (_ success: Bool, _ session: Session?, _ error: Error?) -> Void) {
            let url = "\(Constants.MapMyRun.apiURL)/oauth2/uacf/access_token/"
            let parameters: Parameters = [
                "grant_type": "authorization_code",
                "client_id": Constants.MapMyRun.apiKey,
                "code": code,
                "client_secret": Constants.MapMyRun.apiSecret
            ]
            let headers: HTTPHeaders = ["Api-Key": Constants.MapMyRun.apiKey,
                                        "Content-Type": "application/x-www-form-urlencoded"]
            print(url, parameters, headers)
            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let session = Session(json: json)
                        completion(true, session, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(false, nil, error)
                }
            }
        }
        
        class func getUser(_ session: Session, completion: ((_ success: Bool, _ user: MapMyRunUser?) -> Void)?) {
            
            let url = "\(Constants.MapMyRun.apiURL)/user/self"
            let headers = session.mapMyRunHeaders
            print(url, headers)
            Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let user = MapMyRunUser(json: json, session: session)
                        completion?(true, user)
                    } else {
                        completion?(false, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion?(false, nil)
                }
            }
        }
        
        class func getWorkouts(_ user: MapMyRunUser, completion: @escaping (_ success: Bool, _ workoutIds: [String]) -> Void) {
            let url = "\(Constants.MapMyRun.apiURL)/workout/"
            let headers = user.session?.mapMyRunHeaders
            let parameters: Parameters = ["user": user.id]
            print(url, headers, parameters)
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        var workoutIds: [String] = []
                        for workout in json["_embedded"]["workouts"].arrayValue {
                            if let id = workout["_links"]["self"].arrayValue.first?["id"].string {
                                workoutIds.append(id)
                            }
                        }
                        print(json, workoutIds)
                        completion(true, workoutIds)
                    } else {
                        completion(false, [])
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(false, [])
                }
            }
        }
        
        class func getWorkout(_ user: MapMyRunUser, workoutId: String, completion: @escaping (_ success: Bool, _ workout: Workout?) -> Void) {
            let url = "\(Constants.MapMyRun.apiURL)/workout/\(workoutId)/"
            
            let headers = user.session?.mapMyRunHeaders
            let parameters: Parameters = ["field_set": "time_series"]
            print(url, headers, parameters)
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { response in
                print(response.request?.url)
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        var workout: Workout?
                        print(json, workout)
                        completion(true, workout)
                    } else {
                        completion(false, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(false, nil)
                }
            }
        }
        
    }

}
