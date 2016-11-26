class Context {
    var IdToken : String
    var AccessToken : String
    var URL : String
    init(idToken: String, accessToken : String, URL : String = "http://cloudin.incoding.biz/Dispatcher/Query")
    {
        self.IdToken = idToken
        self.AccessToken = accessToken
        self.URL = URL
    }
}
