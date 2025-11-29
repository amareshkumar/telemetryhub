#pragma once
#include <functional>
#include <string>
#include <map>

namespace httplib {

class Request {
public:
  std::string method;
  std::string path;
  std::string body;
};

class Response {
public:
  int status = 200;
  std::string body;
  void set_content(const std::string& b, const char* /*mime*/) { body = b; }
};

class Server {
public:
  using Handler = std::function<void(const Request&, Response&)>;

  void Get(const char* path, Handler h) { 
    routes_[std::string("GET ")+path] = std::move(h); 
  }
  
  void Post(const char* path, Handler h) { 
    routes_[std::string("POST ")+path] = std::move(h); 
  }
  
  // Stub listen just prints routes; replace with real listen in cpp-httplib
  bool listen(const char* host, int port) {
    (void)host; 
    (void)port; 
    
    return true; // no-op
  }

  // For tests, allow manual dispatch
  bool dispatch(const Request& req, Response& res) {
    auto key = req.method + std::string(" ") + req.path;
    auto it = routes_.find(key);
    
    if (it == routes_.end()) { 
        res.status = 404; res.body = "not found"; return false; 
    }
    it->second(req, res);
    
    return true;
  }

private:
  std::map<std::string, Handler> routes_;
};

} // namespace httplib
