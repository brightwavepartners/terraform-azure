locals {
    app_registration_server = {
        api = {
            identifier_uri = "api://server"
        }
        name = "Server"
        web = {
            redirect_uris = [
                "https://oauth.pstmn.io/v1/callback"                
            ]
        }
    }
}