import Foundation
import Alamofire

final class IssuesEndpoint: PrimeParkEndpoint {
    private static let issuesTypesEndpoint = "/primepark/issues/types"
    private static let issuesListEndpoint = "/primepark/issues"

    func getIssuesTypes(token: String) -> EndpointResponse<[IssueType]> {
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.retrieve(endpoint: Self.issuesTypesEndpoint, parameters: nil, headers: headers)
    }

    func getIssuesList(
        token: String,
        status: String = "assigned, inModeration, closed, accepted, onRoad, inWork, completed, reopened, checking",
        all: Bool = true,
        count: Int32 = 50,
        offset: Int32 = 0                // accumulate offset every scroll down to the end
    ) -> EndpointResponse<[Issue]> {
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["status"] = status
        params["all"] = all
        params["count"] = count
        params["offset"] = offset
        return self.retrieve(endpoint: Self.issuesListEndpoint, parameters: params, headers: headers)
    }

    func createIssue(
        room: Int,
        text: String,
        type: IssueType,
        token: String
    ) -> EndpointResponse<TempIssue> {
        var params: [String: Any] = [:]
        params["room"] = room
        params["text"] = text

        var typeParams: [String: Any] = [:]
        typeParams["id"] = type.id
        typeParams["type"] = type.type
        typeParams["display_name"] = type.name

        params["issue_type"] = typeParams

        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        return self.create(endpoint: Self.issuesListEndpoint, parameters: params, headers: headers, encoding: JSONEncoding.default)
    }
}
