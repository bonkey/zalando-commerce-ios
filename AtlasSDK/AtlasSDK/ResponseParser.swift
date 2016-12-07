//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

struct ResponseParser {

    let taskResponse: DataTaskResponse

    func parse(completion: ResponseCompletion) {
        if let error = taskResponse.error {
            let nsURLError = AtlasAPIError.nsURLError(code: error.code, details: error.localizedDescription)
            return completion(.failure(nsURLError))
        }

        guard let httpResponse = taskResponse.response, let data = taskResponse.data else {
            return completion(.failure(AtlasAPIError.noData))
        }

        let json = JSON(data: data)

        guard httpResponse.isSuccessful else {
            let error: AtlasAPIError
            if httpResponse.status == .unauthorized {
                error = AtlasAPIError.unauthorized
            } else if json != JSON.null {
                error = AtlasAPIError.backend(
                    status: json["status"].int,
                    type: json["type"].string,
                    title: json["title"].string,
                    details: json["detail"].string)
            } else {
                error = AtlasAPIError.http(
                    status: HTTPStatus(response: httpResponse),
                    details: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
            }
            return completion(.failure(error))
        }

        completion(.success(JSONResponse(response: httpResponse, body: json)))
    }

}
