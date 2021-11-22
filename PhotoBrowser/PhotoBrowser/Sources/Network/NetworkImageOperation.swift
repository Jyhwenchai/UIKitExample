//
//  NetworkImageOperation.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/17.
//

import UIKit

typealias ImageDownloadCompletion = ((Data?, Error?) -> Void)?

final class NetworkImageOperation: AsyncOperation, URLSessionDownloadDelegate {
    var image: UIImage?
    var data: Data?
    
    private let url: URL
    private let completion: ImageDownloadCompletion
    private weak var session: URLSession?
    private var downloadTask: URLSessionDownloadTask?
    
    var progressClosure: ((Double) -> Void)?
    
    init(url: URL, completion: ImageDownloadCompletion = nil) {
        self.url = url
        self.completion = completion
        super.init()
    }
    
    convenience init?(string: String, completion: ImageDownloadCompletion = nil) {
        guard let url = URL(string: string) else { return nil }
        self.init(url: url, completion: completion)
    }
    
    override func cancel() {
        super.cancel()
        if let downloadTask = downloadTask, downloadTask.state != .canceling {
            downloadTask.cancel()
        }
    }
    
    override func main() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Accept-Encoding":""]
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
        self.session = session
        self.downloadTask = downloadTask
        state = .executing
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if downloadTask == self.downloadTask, let progressClosure = progressClosure {
            let calculatedProgress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            progressClosure(calculatedProgress)
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let data = readDownloadedData(of: location) else { return }
        self.data = data
        self.image = UIImage(data: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.state = .finished
        completion?(data, error)
        if error != nil {
            session.invalidateAndCancel()
        } else {
            session.finishTasksAndInvalidate()
        }
        downloadTask = nil
        self.session = nil
    }
    
    // MARK: read downloaded data
    private func readDownloadedData(of url: URL) -> Data? {
        do {
            let reader = try FileHandle(forReadingFrom: url)
            let data = reader.readDataToEndOfFile()
            return data
        } catch {
            return nil
        }
    }
    
}
