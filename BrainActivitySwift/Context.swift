class Context {
    var IdToken : String
    var AccessToken : String
    var URL : String
    init(idToken: String, accessToken : String, URL : String)
    {
        self.IdToken = idToken
        self.AccessToken = accessToken
        self.URL = URL
    }
}