//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import AtlasSDK

class APICustomerSpec: APIClientBaseSpec {

    override func spec() {

        describe("Customer API") {

            let customerUrl = NSURL(validUrl: "https://atlas-sdk.api/api/customer")

            it("should make successful request") {
                let json = ["customer_number": "12345678", "gender": "MALE", "email": "aaa@a.a",
                    "first_name": "John", "last_name": "Doe"]
                let customerResponse = self.dataWithJSONObject(json)
                let client = self.mockedAPIClient(forURL: customerUrl, data: customerResponse, statusCode: 200)

                waitUntil(timeout: 60) { done in
                    client.customer { result in
                        defer { done() }
                        guard case let .success(customer) = result else {
                            fail("Should return Customer")
                            return
                        }

                        expect(customer.customerNumber).to(equal("12345678"))
                        expect(customer.gender).to(equal(Customer.Gender.Male))
                        expect(customer.email).to(equal("aaa@a.a"))
                        expect(customer.firstName).to(equal("John"))
                        expect(customer.lastName).to(equal("Doe"))
                    }
                }
            }

        }
    }
}
