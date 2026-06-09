import Foundation

public final class URLSessionAPIClient: APIClientProtocol, @unchecked Sendable {
    private let configuration: NetworkConfiguration
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(configuration: NetworkConfiguration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    public func request<T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        let data = try await perform(endpoint)
        guard !data.isEmpty else {
            throw NetworkError.decodingFailed
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    public func request(_ endpoint: Endpoint) async throws {
        _ = try await perform(endpoint)
    }

    private func perform(_ endpoint: Endpoint) async throws -> Data {
        let request = try buildRequest(for: endpoint)
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.serverError(0)
            }
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 404:
                throw NetworkError.notFound
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.noConnection
        } catch let error as URLError where error.code == .timedOut {
            throw NetworkError.timeout
        } catch {
            throw NetworkError.serverError(0)
        }
    }

    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }
        let basePath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let endpointPath = endpoint.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if basePath.isEmpty {
            components.path = "/\(endpointPath)"
        } else {
            components.path = "/\(basePath)/\(endpointPath)"
        }
        components.queryItems = endpoint.queryItems
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = configuration.timeout
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.httpBody = endpoint.body
        return request
    }
}
