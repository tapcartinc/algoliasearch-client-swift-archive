//
//  Copyright (c) 2015 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// A proxy to an Algolia index.
///
/// + Note: You cannot construct this class directly. Please use `Client.getIndex(_:)` to obtain an instance.
///
@objc open class Index : NSObject {
    // MARK: Properties
    
    /// This index's name.
    @objc open let indexName: String
    
    /// API client used by this index.
    @objc open let client: Client
    
    let urlEncodedIndexName: String
    
    var searchCache: ExpiringCache?
    
    // MAR: - Initialization
    
    /// Create a new index proxy.
    @objc init(client: Client, indexName: String) {
        self.client = client
        self.indexName = indexName
        urlEncodedIndexName = indexName.urlEncodedPathComponent()
    }

    override open var description: String {
        get {
            return "Index{\"\(indexName)\"}"
        }
    }
    
    // MARK: - Operations

    /// Add an object to this index.
    ///
    /// - parameter object: The object to add.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func addObject(_ object: JSONObject, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)"
        return client.performHTTPQuery(path, method: .POST, body: object, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Add an object to this index, assigning it the specified object ID.
    /// If an object already exists with the same object ID, the existing object will be overwritten.
    ///
    /// - parameter object: The object to add.
    /// - parameter withID: Identifier that you want to assign this object.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func addObject(_ object: JSONObject, withID objectID: String, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncodedPathComponent())"
        return client.performHTTPQuery(path, method: .PUT, body: object, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Add several objects to this index.
    ///
    /// - parameter objects: Objects to add.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func addObjects(_ objects: [JSONObject], completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [Any]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            requests.append(["action": "addObject", "body": object])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Delete an object from this index.
    ///
    /// - parameter objectID: Identifier of object to delete.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func deleteObject(_ objectID: String, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncodedPathComponent())"
        return client.performHTTPQuery(path, method: .DELETE, body: nil, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Delete several objects from this index.
    ///
    /// - parameter objectIDs: Identifiers of objects to delete.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func deleteObjects(_ objectIDs: [String], completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [Any]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            requests.append(["action": "deleteObject", "objectID": id])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Get an object from this index.
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func getObject(_ objectID: String, completionHandler: CompletionHandler) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncodedPathComponent())"
        return client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Get an object from this index, optionally restricting the retrieved content.
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - parameter attributesToRetrieve: List of attributes to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func getObject(_ objectID: String, attributesToRetrieve attributes: [String], completionHandler: CompletionHandler) -> Operation {
        let query = Query()
        query.attributesToRetrieve = attributes
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncodedPathComponent())?\(query.build())"
        return client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Get several objects from this index.
    ///
    /// - parameter objectIDs: Identifiers of objects to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func getObjects(_ objectIDs: [String], completionHandler: CompletionHandler) -> Operation {
        let path = "1/indexes/*/objects"
        
        var requests = [Any]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            requests.append(["indexName": indexName, "objectID": id])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.readHosts, completionHandler: completionHandler)
    }

    /// Get several objects from this index, optionally restricting the retrieved content.
    ///
    /// - parameter objectIDs: Identifiers of objects to retrieve.
    /// - parameter attributesToRetrieve: List of attributes to retrieve. If `nil`, all attributes are retrieved.
    ///                                   If one of the elements is `"*"`, all attributes are retrieved.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func getObjects(_ objectIDs: [String], attributesToRetrieve: [String], completionHandler: CompletionHandler) -> Operation {
        let path = "1/indexes/*/objects"
        var requests = [Any]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            let request = [
                "indexName": indexName,
                "objectID": id,
                "attributesToRetrieve": attributesToRetrieve.joined(separator: ",")
            ]
            requests.append(request as Any)
        }
        return client.performHTTPQuery(path, method: .POST, body: ["requests": requests], hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Partially update an object.
    ///
    /// - parameter partialObject: New values/operations for the object.
    /// - parameter objectID: Identifier of object to be updated.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func partialUpdateObject(_ partialObject: JSONObject, objectID: String, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncodedPathComponent())/partial"
        return client.performHTTPQuery(path, method: .POST, body: partialObject, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Partially update several objects.
    ///
    /// - parameter objects: New values/operations for the objects. Each object must contain an `objectID` attribute.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func partialUpdateObjects(_ objects: [JSONObject], completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [Any]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            requests.append([
                "action": "partialUpdateObject",
                "objectID": object["objectID"] as! String,
                "body": object
            ])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Update an object.
    ///
    /// - parameter object: New version of the object to update. Must contain an `objectID` attribute.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func saveObject(_ object: JSONObject, completionHandler: CompletionHandler? = nil) -> Operation {
        let objectID = object["objectID"] as! String
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncodedPathComponent())"
        return client.performHTTPQuery(path, method: .PUT, body: object, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Update several objects.
    ///
    /// - parameter objects: New versions of the objects to update. Each one must contain an `objectID` attribute.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func saveObjects(_ objects: [JSONObject], completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [Any]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            requests.append([
                "action": "updateObject",
                "objectID": object["objectID"] as! String,
                "body": object
            ])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Search this index.
    ///
    /// - parameter query: Search parameters.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func search(_ query: Query, completionHandler: CompletionHandler) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/query"
        let request = ["params": query.build()]
        
        // First try the in-memory query cache.
        let cacheKey = "\(path)_body_\(request)"
        if let content = searchCache?.objectForKey(cacheKey) {
            // We *have* to return something, so we create a completionHandler operation.
            // Note that its execution will be deferred until the next iteration of the main run loop.
            let operation = BlockOperation() {
                completionHandler(content, nil)
            }
            OperationQueue.main.addOperation(operation)
            return operation
        }
        // Otherwise, run an online query.
        else {
            return client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.readHosts, isSearchQuery: true) {
                (content, error) -> Void in
                assert(content != nil || error != nil)
                if content != nil {
                    self.searchCache?.setObject(content!, forKey: cacheKey)
                    completionHandler(content, error)
                } else {
                    completionHandler(content, error)
                }
            }
        }
    }
    
    /// Get this index's settings.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func getSettings(_ completionHandler: CompletionHandler) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        return client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Set this index's settings.
    ///
    /// Please refer to our [API documentation](https://www.algolia.com/doc/swift#index-settings) for the list of
    /// supported settings.
    ///
    /// - parameter settings: New settings.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func setSettings(_ settings: JSONObject, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        return client.performHTTPQuery(path, method: .PUT, body: settings, hostnames: client.writeHosts, completionHandler: completionHandler)
    }

    /// Set this index's settings, optionally forwarding the change to slave indices.
    ///
    /// Please refer to our [API documentation](https://www.algolia.com/doc/swift#index-settings) for the list of
    /// supported settings.
    ///
    /// - parameter settings: New settings.
    /// - parameter forwardToSlaves: When true, the change is also applied to slaves of this index.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func setSettings(_ settings: JSONObject, forwardToSlaves: Bool, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/settings?forwardToSlaves=\(forwardToSlaves)"
        return client.performHTTPQuery(path, method: .PUT, body: settings, hostnames: client.writeHosts, completionHandler: completionHandler)
    }

    /// Delete the index content without removing settings and index specific API keys.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func clearIndex(_ completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/clear"
        return client.performHTTPQuery(path, method: .POST, body: nil, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Batch operations.
    ///
    /// - parameter operations: The array of actions.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func batch(_ operations: [JSONObject], completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        let body = ["requests": operations]
        return client.performHTTPQuery(path, method: .POST, body: body, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Browse all index content (initial call).
    /// This method should be called once to initiate a browse. It will return the first page of results and a cursor,
    /// unless the end of the index has been reached. To retrieve subsequent pages, call `browseFrom` with that cursor.
    ///
    /// - parameter query: The query parameters for the browse.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func browse(_ query: Query, completionHandler: CompletionHandler) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/browse"
        let body = [
            "params": query.build()
        ]
        return client.performHTTPQuery(path, method: .POST, body: body, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Browse the index from a cursor.
    /// This method should be called after an initial call to `browse()`. It returns a cursor, unless the end of the
    /// index has been reached.
    ///
    /// - parameter cursor: The cursor of the next page to retrieve
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func browseFrom(_ cursor: String, completionHandler: CompletionHandler) -> Operation {
        let path = "1/indexes/\(urlEncodedIndexName)/browse?cursor=\(cursor.urlEncodedQueryParam())"
        return client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    // MARK: - Helpers
    
    /// Wait until the publication of a task on the server (helper).
    /// All server tasks are asynchronous. This method helps you check that a task is published.
    ///
    /// - parameter taskID: Identifier of the task (as returned by the server).
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func waitTask(_ taskID: Int, completionHandler: CompletionHandler) -> Operation {
        let operation = WaitOperation(index: self, taskID: taskID, completionHandler: completionHandler)
        operation.start()
        return operation
    }
    
    fileprivate class WaitOperation: AsyncOperation {
        let index: Index
        let taskID: Int
        let completionHandler: CompletionHandler
        let path: String
        var iteration: Int = 0
        
        static let BASE_DELAY = 0.1     ///< Minimum wait delay.
        static let MAX_DELAY  = 5.0     ///< Maximum wait delay.
        
        init(index: Index, taskID: Int, completionHandler: CompletionHandler) {
            self.index = index
            self.taskID = taskID
            self.completionHandler = completionHandler
            path = "1/indexes/\(index.urlEncodedIndexName)/task/\(taskID)"
        }
        
        override func start() {
            super.start()
            startNext()
        }
        
        fileprivate func startNext() {
            if isCancelled {
                finish()
            }
            iteration += 1
            index.client.performHTTPQuery(path, method: .GET, body: nil, hostnames: index.client.writeHosts) {
                (content, error) -> Void in
                if let content = content {
                    if (content["status"] as? String) == "published" {
                        if !self.isCancelled {
                            self.completionHandler(content, nil)
                        }
                        self.finish()
                    } else {
                        // The delay between polls increases quadratically from the base delay up to the max delay.
                        let delay = min(WaitOperation.BASE_DELAY * Double(self.iteration * self.iteration), WaitOperation.MAX_DELAY)
                        Thread.sleep(forTimeInterval: delay)
                        self.startNext()
                    }
                } else {
                    if !self.isCancelled {
                        self.completionHandler(content, error)
                    }
                    self.finish()
                }
            }
        }
    }

    /// Delete all objects matching a query (helper).
    ///
    /// - parameter query: The query that objects to delete must match.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func deleteByQuery(_ query: Query, completionHandler: CompletionHandler? = nil) -> Operation {
        let operation = DeleteByQueryOperation(index: self, query: query, completionHandler: completionHandler)
        operation.start()
        return operation
    }
    
    fileprivate class DeleteByQueryOperation: AsyncOperation {
        let index: Index
        let query: Query
        let completionHandler: CompletionHandler?
        
        init(index: Index, query: Query, completionHandler: CompletionHandler?) {
            self.index = index
            self.query = Query(copy: query)
            self.completionHandler = completionHandler
        }
        
        override func start() {
            super.start()
            // Save bandwidth by retrieving only the `objectID` attribute.
            query.attributesToRetrieve = ["objectID"]
            index.browse(query, completionHandler: self.handleResult)
        }
        
        fileprivate func handleResult(_ content: JSONObject?, error: NSError?) {
            if self.isCancelled {
                return
            }
            var finalError: NSError? = error
            if finalError == nil {
                let hasMoreContent = content!["cursor"] != nil
                if let hits = content!["hits"] as? [Any] {
                    // Fetch IDs of objects to delete.
                    var objectIDs: [String] = []
                    for hit in hits {
                        if let objectID = (hit as? JSONObject)?["objectID"] as? String {
                            objectIDs.append(objectID)
                        }
                    }
                    // Delete the objects.
                    self.index.deleteObjects(objectIDs, completionHandler: { (content, error) in
                        if self.isCancelled {
                            return
                        }
                        var finalError: NSError? = error
                        if finalError == nil {
                            if let taskID = content?["taskID"] as? Int {
                                // Wait for the deletion to be effective.
                                self.index.waitTask(taskID, completionHandler: { (content, error) in
                                    if self.isCancelled {
                                        return
                                    }
                                    if error != nil || !hasMoreContent {
                                        self.finish(content, error: error)
                                    } else {
                                        // Browse again *from the beginning*, since the deletion invalidated the cursor.
                                        self.index.browse(self.query, completionHandler: self.handleResult)
                                    }
                                })
                            } else {
                                finalError = NSError(domain: Client.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No task ID returned when deleting"])
                            }
                        }
                        if finalError != nil {
                            self.finish(nil, error: finalError)
                        }
                    })
                } else {
                    finalError = NSError(domain: Client.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No hits returned when browsing"])
                }
            }
            if finalError != nil {
                self.finish(nil, error: finalError)
            }
        }
        
        fileprivate func finish(_ content: JSONObject?, error: NSError?) {
            if !isCancelled {
                self.completionHandler?(nil, error)
            }
            self.finish()
        }
    }
    
    /// Perform a search with disjunctive facets, generating as many queries as number of disjunctive facets (helper).
    ///
    /// - parameter query: The query.
    /// - parameter disjunctiveFacets: List of disjunctive facets.
    /// - parameter refinements: The current refinements, mapping facet names to a list of values.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func searchDisjunctiveFaceting(_ query: Query, disjunctiveFacets: [String], refinements: [String: [String]], completionHandler: CompletionHandler) -> Operation {
        var queries = [Query]()
        
        // Build the first, global query.
        let globalQuery = Query(copy: query)
        globalQuery.facetFilters = Index._buildFacetFilters(disjunctiveFacets, refinements: refinements, excludedFacet: nil)
        queries.append(globalQuery)
        
        // Build the refined queries.
        for disjunctiveFacet in disjunctiveFacets {
            let disjunctiveQuery = Query(copy: query)
            disjunctiveQuery.facets = [disjunctiveFacet]
            disjunctiveQuery.facetFilters = Index._buildFacetFilters(disjunctiveFacets, refinements: refinements, excludedFacet: disjunctiveFacet)
            // We are not interested in the hits for this query, only the facet counts, so let's limit the output.
            disjunctiveQuery.hitsPerPage = 0
            disjunctiveQuery.attributesToRetrieve = []
            disjunctiveQuery.attributesToHighlight = []
            disjunctiveQuery.attributesToSnippet = []
            // Do not show this query in analytics, either.
            disjunctiveQuery.analytics = false
            queries.append(disjunctiveQuery)
        }
        
        // Run all the queries.
        let operation = self.multipleQueries(queries, completionHandler: { (content, error) -> Void in
            var finalContent: JSONObject? = nil
            var finalError: NSError? = error
            if error == nil {
                do {
                    finalContent = try Index._aggregateResults(disjunctiveFacets, refinements: refinements, content: content!)
                } catch let e as NSError {
                    finalError = e
                }
            }
            assert(finalContent != nil || finalError != nil)
            completionHandler(finalContent, finalError)
        })
        return operation
    }
    
    /// Run multiple queries on this index.
    /// This method is a variant of `Client.multipleQueries(...)` where the targeted index is always the receiver.
    ///
    /// - parameter queries: The queries to run.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult @objc open func multipleQueries(_ queries: [Query], strategy: String?, completionHandler: CompletionHandler) -> Operation {
        var requests = [IndexQuery]()
        for query in queries {
            requests.append(IndexQuery(index: self, query: query))
        }
        return client.multipleQueries(requests, strategy: strategy, completionHandler: completionHandler)
    }
    
    /// Run multiple queries on this index.
    /// This method is a variant of `Client.multipleQueries(...)` where the targeted index is always the receiver.
    ///
    /// - parameter queries: The queries to run.
    /// - parameter strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult open func multipleQueries(_ queries: [Query], strategy: Client.MultipleQueriesStrategy? = nil, completionHandler: CompletionHandler) -> Operation {
        return self.multipleQueries(queries, strategy: strategy?.rawValue, completionHandler: completionHandler)
    }
    
    /// Aggregate disjunctive faceting search results.
    fileprivate class func _aggregateResults(_ disjunctiveFacets: [String], refinements: [String: [String]], content: JSONObject) throws -> JSONObject {
        guard let results = content["results"] as? [Any] else {
            throw NSError(domain: Client.ErrorDomain, code: StatusCode.invalidResponse.rawValue, userInfo: [NSLocalizedDescriptionKey: "No results in response"])
        }
        // The first answer is used as the basis for the response.
        guard var mainContent = results[0] as? JSONObject else {
            throw NSError(domain: Client.ErrorDomain, code: StatusCode.invalidResponse.rawValue, userInfo: [NSLocalizedDescriptionKey: "Invalid results in response"])
        }
        // Following answers are just used for their facet counts.
        var disjunctiveFacetCounts = JSONObject()
        for i in 1..<results.count { // for each answer (= each disjunctive facet)
            guard let result = results[i] as? JSONObject, let allFacetCounts = result["facets"] as? [String: [String: Any]] else {
                throw NSError(domain: Client.ErrorDomain, code: StatusCode.invalidResponse.rawValue, userInfo: [NSLocalizedDescriptionKey: "Invalid results in response"])
            }
            // NOTE: Iterating, but there should be just one item.
            for (facetName, facetCounts) in allFacetCounts {
                var newFacetCounts = facetCounts
                // Add zeroes for missing values.
                if disjunctiveFacets.contains(facetName) {
                    if let refinedValues = refinements[facetName] {
                        for refinedValue in refinedValues {
                            if facetCounts[refinedValue] == nil {
                                newFacetCounts[refinedValue] = 0
                            }
                        }
                    }
                }
                disjunctiveFacetCounts[facetName] = newFacetCounts
            }
            // If facet counts are not exhaustive, propagate this information to the main results.
            // Because disjunctive queries are less restrictive than the main query, it can happen that the main query
            // returns exhaustive facet counts, while the disjunctive queries do not.
            if let exhaustiveFacetsCount = result["exhaustiveFacetsCount"] as? Bool {
                if !exhaustiveFacetsCount {
                    mainContent["exhaustiveFacetsCount"] = false
                }
            }
        }
        mainContent["disjunctiveFacets"] = disjunctiveFacetCounts
        return mainContent
    }
    
    /// Build the facet filters, either global or for the selected disjunctive facet.
    ///
    /// - parameter excludedFacet: The disjunctive facet to exclude from the filters. If nil, no facet is
    ///   excluded (thus building the global filters).
    ///
    fileprivate class func _buildFacetFilters(_ disjunctiveFacets: [String], refinements: [String: [String]], excludedFacet: String?) -> [Any] {
        var facetFilters: [Any] = []
        for (facetName, facetValues) in refinements {
            // Disjunctive facet: OR all values, and AND with the rest of the filters.
            if disjunctiveFacets.contains(facetName) {
                // Skip the specified disjunctive facet, if any.
                if facetName == excludedFacet {
                    continue
                }
                var disjunctiveOperator = [String]()
                for facetValue in facetValues {
                    disjunctiveOperator.append("\(facetName):\(facetValue)")
                }
                facetFilters.append(disjunctiveOperator as Any)
            }
                // Conjunctive facet: AND all values with the rest of the filters.
            else {
                assert(facetName != excludedFacet)
                for facetValue in facetValues {
                    facetFilters.append("\(facetName):\(facetValue)")
                }
            }
        }
        return facetFilters
    }

    // MARK: - Search Cache
    
    /// Enable the search cache.
    ///
    /// - parameter expiringTimeInterval: Each cached search will be valid during this interval of time.
    ///
    @objc open func enableSearchCache(_ expiringTimeInterval: TimeInterval = 120) {
        searchCache = ExpiringCache(expiringTimeInterval: expiringTimeInterval)
    }
    
    /// Disable the search cache.
    ///
    @objc open func disableSearchCache() {
        searchCache?.clearCache()
        searchCache = nil
    }
    
    /// Clear the search cache.
    ///
    @objc open func clearSearchCache() {
        searchCache?.clearCache()
    }
}
