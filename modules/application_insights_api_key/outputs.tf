output "api_key" {
    value = data.http.encrypted_ai_api_key.body  
}