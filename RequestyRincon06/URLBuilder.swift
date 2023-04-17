//
//  URLBuilder.swift
//  RequestyRincón05
//
//  Created by Nick Rodriguez on 16/04/2023.
//

import Foundation


struct URLBuilder {
    
    static func createUrl() -> URL{
        let baseURLString = "http://127.0.0.1:5001/rincon_posts_payload04/"
        let components = URLComponents(string:baseURLString)!

        
        return components.url!
    }
}
