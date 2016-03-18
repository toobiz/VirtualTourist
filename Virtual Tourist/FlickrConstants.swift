//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Michał Tubis on 14.03.2016.
//  Copyright © 2016 Weblify. All rights reserved.
//

extension FlickrClient {
    
    struct Constants {
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let METHOD_NAME = "flickr.photos.search"
        static let API_KEY = "431e66a50d56630e7bf76f7231534aa0"
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        static let BOUNDING_BOX_HALF_WIDTH = 0.05
        static let BOUNDING_BOX_HALF_HEIGHT = 0.05
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
    }
    

    
}
