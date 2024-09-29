resource "keycloak_realm" "croeer_prod" {
  realm   = "croeer-prod"
  enabled = true
}

resource "keycloak_openid_client" "wordpress_csartsde_openid_client" {
  realm_id  = keycloak_realm.croeer_prod.id
  client_id = "wordpress-csartsde-client"

  name    = "Wordpress cs-arts.de client"
  enabled = true

  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://cs-arts.de/*",
    "https://www.cs-arts.de/*"
  ]
  web_origins = ["https://cs-arts.de/*",
  "https://www.cs-arts.de/*"]
  standard_flow_enabled = true

}
