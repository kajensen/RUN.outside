//
//  API.swift
//  RUN
//
//  Created by Kurt Jensen on 3/28/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import SwiftyJSON
import Alamofire

class API: NSObject {
    
    
    // http://openweathermap.org/current
    /*
     {"coord":{"lon":139,"lat":35},
     "sys":{"country":"JP","sunrise":1369769524,"sunset":1369821049},
     "weather":[{"id":804,"main":"clouds","description":"overcast clouds","icon":"04n"}],
     "main":{"temp":289.5,"humidity":89,"pressure":1013,"temp_min":287.04,"temp_max":292.04},
     "wind":{"speed":7.31,"deg":187.002},
     "rain":{"3h":0},
     "clouds":{"all":92},
     "dt":1369824698,
     "id":1851632,
     "name":"Shuzenji",
     "cod":200}
    */
    class func getCurrentWeather(_ lat: Double, lng: Double, completion: @escaping (_ success: Bool, _ weather: Weather?) -> Void) {
        let url = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lng)&appid=\(Constants.openWeatherApiKey)"
        Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    let temperature = json["main"]["temp"].doubleValue
                    if temperature > 0 {
                        let weatherJSON = json["weather"].array?.first
                        let weather = Weather(temperatureInKelvin: temperature, description: weatherJSON?["description"].string, id: weatherJSON?["id"].stringValue)
                        completion(true, weather)
                    } else {
                        completion(false, nil)
                    }
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
