//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectLib
import PerfectMustache



//struct Filter404: HTTPResponseFilter {
//    func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
//        callback(.continue)
//    }
//    
//    func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
//        if case .notFound = response.status {
//            response.bodyBytes.removeAll()
//            response.setBody(string: "The file \(response.request.path) was not found.")
//            response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
//            callback(.done)
//        } else {
//            callback(.continue)
//        }
//    }
//}


// Create HTTP server.
let server = HTTPServer()

//server.setResponseFilters([(Filter404(), .high)])

var oneSet = false
var towSet = false
var threeSet = false

struct Filter1: HTTPRequestFilter {
    func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
        oneSet = true
        callback(.continue(request, response))
    }
}

struct Filter2: HTTPRequestFilter {
    func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
        assert(oneSet)
        assert(!towSet && !threeSet)
        towSet = true
        callback(.execute(request, response))
    }
}

struct Filter3: HTTPRequestFilter {
    func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
        assert(false, "This filter should be skipped")
        callback(.continue(request, response))
    }
}

struct Filter4: HTTPRequestFilter {
    func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
        assert(oneSet && towSet)
        assert(!threeSet)
        threeSet = true
        callback(.halt(request, response))
    }
}

//server.setRequestFilters([(Filter1(), .high),
//                          (Filter2(), .medium),
//                          (Filter3(), .medium),
//                          (Filter4(), .low)])
// Register your own routes and handlers
var routes = Routes()


var baseApi = Routes()


baseApi.add(method: .get, uri: "/", handler: {
		request, response in
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
		response.completed()
	}
)

baseApi.add(method: .post, uri: "/my", handler: {
    request, response in
    
    var scoreArray: [String : Any] = ["第一名": 300, "第二名": 230.45, "第三名": 150]

    if let foo = request.param(name: "foo") {
        if let doubleFoo = Double(foo) {
            scoreArray.updateValue(doubleFoo, forKey: "第四名")
        }
    }

    if let five = request.param(name: "five") {
        if let doubleFive = Double(five) {
            scoreArray.updateValue(doubleFive, forKey: "第五名")
            scoreArray.updateValue(["恩和":"不及格"], forKey: "第六名")
        }
    }

    
    response.setHeader(.contentType, value: "text/json")
    var encoded: String;
    do {
        encoded =  try scoreArray.jsonEncodedString()
    } catch {
        encoded = "";
    }

    
    

    response.appendBody(string: encoded);
    response.completed()

    
})

baseApi.add(method: .get, uri: "/avatar") { (request, response) in
    
    let docRoot = request.documentRoot
    
    do {
        let imageFile = File(docRoot + "/IMG_5505.JPG")
        let imageSize = imageFile.size
        let imageBytes = try imageFile.readSomeBytes(count: imageSize);
       
        response.setHeader(.contentType, value: "jpg")
        response.setHeader(.contentLength, value: "\(imageBytes.count)")
        response.setBody(bytes: imageBytes)
    } catch {
        response.status = .internalServerError
        response.setBody(string: "请求处理出现错误：\(error)")
    }
    
    response.completed()
}



var v1 = Routes(baseUri: "/v1")

v1.add(baseApi)


var v2 = Routes(baseUri: "/v2");

v2.add(baseApi)
v2.add(method: .get, uri: "/avatar") { (request, response) in
    
    response.setHeader(.contentType, value: "text/json")
    response.appendBody(string: try! "v2重写 avatar".jsonEncodedString())
    
    response.completed()
}


v2.add(method: .get, uri: "/{userid}/info") { (request, response) in
    
    if let userID = request.urlVariables["userid"] {
        let info = ["id":userID, "name":"qxy", "age":"24", "birthday":"1992.09.28"]
        response.appendBody(string: try! info.jsonEncodedString())
    } else {
        response.appendBody(string: try! "user ID is NULL".jsonEncodedString())
    }
    
    
    response.addHeader(.contentType, value: "text/json")
    response.completed()
}

v2.add(method: .post, uri: "/upload") { (request, response) in
    
    mustacheRequest(request: request, response: response, handler: UploadHandler(), templatePath: server.documentRoot + "/response.mustache")
    
}

//routes.add(baseApi)
//routes.add(v1)
//routes.add(v2)

server.serverName = "qxy"

// Add the routes to the server.
//server.addRoutes(routes)
server.addRoutes(baseApi)
server.addRoutes(v1)
server.addRoutes(v2)

// Set a listen port of 8181
server.serverPort = 8181

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**
server.documentRoot = "./webroot"

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
