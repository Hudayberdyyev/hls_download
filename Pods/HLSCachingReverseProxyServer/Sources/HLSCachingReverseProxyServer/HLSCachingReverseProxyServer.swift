import GCDWebServer
import PINCache

open class HLSCachingReverseProxyServer {
  static let originURLKey = "__hls_origin_url"

  private let webServer: GCDWebServer
  private let urlSession: URLSession
  private let cache: PINCaching

  private(set) var port: Int?

  public init(webServer: GCDWebServer, urlSession: URLSession, cache: PINCaching) {
    self.webServer = webServer
    self.urlSession = urlSession
    self.cache = cache

    self.addRequestHandlers()
  }


  // MARK: Starting and Stopping Server

  open func start(port: UInt) {
    guard !self.webServer.isRunning else { return }
    self.port = Int(port)
    self.webServer.start(withPort: port, bonjourName: nil)
  }

  open func stop() {
    guard self.webServer.isRunning else { return }
    self.port = nil
    self.webServer.stop()
  }


  // MARK: Resource URL

  open func reverseProxyURL(from originURL: URL) -> URL? {
    guard let port = self.port else { return nil }

    guard var components = URLComponents(url: originURL, resolvingAgainstBaseURL: false) else { return nil }
    components.scheme = "http"
    components.host = "127.0.0.1"
    components.port = port

    let originURLQueryItem = URLQueryItem(name: Self.originURLKey, value: originURL.absoluteString)
    components.queryItems = (components.queryItems ?? []) + [originURLQueryItem]

    return components.url
  }


  // MARK: Request Handler

  private func addRequestHandlers() {
    self.addPlaylistHandler()
    self.addSegmentHandler()
  }

  private func addPlaylistHandler() {
    self.webServer.addHandler(forMethod: "GET", pathRegex: "^/.*\\.m3u8$", request: GCDWebServerRequest.self) { [weak self] request, completion in
      guard let self = self else {
        return completion(GCDWebServerDataResponse(statusCode: 500))
      }

      guard let originURL = self.originURL(from: request) else {
        return completion(GCDWebServerErrorResponse(statusCode: 400))
      }

      let task = self.urlSession.dataTask(with: originURL) { data, response, error in
        guard let data = data, let response = response else {
          return completion(GCDWebServerErrorResponse(statusCode: 500))
        }

        let playlistData = self.reverseProxyPlaylist(with: data, forOriginURL: originURL)
        let contentType = response.mimeType ?? "application/x-mpegurl"
        completion(GCDWebServerDataResponse(data: playlistData, contentType: contentType))
      }

      task.resume()
    }
  }

  private func addSegmentHandler() {
    self.webServer.addHandler(forMethod: "GET", pathRegex: "^/.*\\.ts$", request: GCDWebServerRequest.self) { [weak self] request, completion in
      guard let self = self else {
        return completion(GCDWebServerDataResponse(statusCode: 500))
      }

      guard let originURL = self.originURL(from: request) else {
        return completion(GCDWebServerErrorResponse(statusCode: 400))
      }

      if let cachedData = self.cachedData(for: originURL) {
        return completion(GCDWebServerDataResponse(data: cachedData, contentType: "video/mp2t"))
      }

      let task = self.urlSession.dataTask(with: originURL) { data, response, error in
        guard let data = data, let response = response else {
          return completion(GCDWebServerErrorResponse(statusCode: 500))
        }

        let contentType = response.mimeType ?? "video/mp2t"
        completion(GCDWebServerDataResponse(data: data, contentType: contentType))

        self.saveCacheData(data, for: originURL)
      }

      task.resume()
    }
  }

  private func originURL(from request: GCDWebServerRequest) -> URL? {
    guard let encodedURLString = request.query?[Self.originURLKey] else { return nil }
    guard let urlString = encodedURLString.removingPercentEncoding else { return nil }
    let url = URL(string: urlString)
    return url
  }


  // MARK: Manipulating Playlist

  private func reverseProxyPlaylist(with data: Data, forOriginURL originURL: URL) -> Data {
    return String(data: data, encoding: .utf8)!
      .components(separatedBy: .newlines)
      .map { line in self.processPlaylistLine(line, forOriginURL: originURL) }
      .joined(separator: "\n")
      .data(using: .utf8)!
  }

  private func processPlaylistLine(_ line: String, forOriginURL originURL: URL) -> String {
    guard !line.isEmpty else { return line }

    if line.hasPrefix("#") {
      return self.lineByReplacingURI(line: line, forOriginURL: originURL)
    }

    if let originalSegmentURL = self.absoluteURL(from: line, forOriginURL: originURL),
      let reverseProxyURL = self.reverseProxyURL(from: originalSegmentURL) {
      return reverseProxyURL.absoluteString
    }

    return line
  }

  private func lineByReplacingURI(line: String, forOriginURL originURL: URL) -> String {
    let uriPattern = try! NSRegularExpression(pattern: "URI=\"(.*)\"")
    let lineRange = NSMakeRange(0, line.count)
    guard let result = uriPattern.firstMatch(in: line, options: [], range: lineRange) else { return line }

    let uri = (line as NSString).substring(with: result.range(at: 1))
    guard let absoluteURL = self.absoluteURL(from: uri, forOriginURL: originURL) else { return line }
    guard let reverseProxyURL = self.reverseProxyURL(from: absoluteURL) else { return line }

    return uriPattern.stringByReplacingMatches(in: line, options: [], range: lineRange, withTemplate: "URI=\"\(reverseProxyURL.absoluteString)\"")
  }

  private func absoluteURL(from line: String, forOriginURL originURL: URL) -> URL? {
    guard ["m3u8", "ts"].contains(originURL.pathExtension) else { return nil }

    if line.hasPrefix("http://") || line.hasPrefix("https://") {
      return URL(string: line)
    }

    guard let scheme = originURL.scheme, let host = originURL.host else { return nil }

    let path: String
    if line.hasPrefix("/") {
      path = line
    } else {
      path = originURL.deletingLastPathComponent().appendingPathComponent(line).path
    }

    return URL(string: scheme + "://" + host + path)?.standardized
  }


  // MARK: Caching

  private func cachedData(for resourceURL: URL) -> Data? {
    let key = self.cacheKey(for: resourceURL)
    return self.cache.object(forKey: key) as? Data
  }

  private func saveCacheData(_ data: Data, for resourceURL: URL) {
    let key = self.cacheKey(for: resourceURL)
    self.cache.setObject(data, forKey: key)
  }

  private func cacheKey(for resourceURL: URL) -> String {
    return resourceURL.absoluteString.data(using: .utf8)!.base64EncodedString()
  }
}
