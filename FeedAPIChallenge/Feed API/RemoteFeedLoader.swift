//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
		
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success((let data, let httpResponse)):
                completion(RemoteFeedLoader.mapFeedItem(data: data, httpResponse: httpResponse))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        } 
    }
    
    private static func mapFeedItem(data: Data, httpResponse: HTTPURLResponse) -> FeedLoader.Result {
        guard httpResponse.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(Error.invalidData)
        }
        
        return .success(root.items)
    }
    
    struct Root: Decodable {
        var items: [FeedImage]
    }
}
