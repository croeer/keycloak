resource "keycloak_realm" "croeer_test" {
  realm   = "croeer-test"
  enabled = true
}

resource "keycloak_openid_client" "plungestreak_openid_client" {
  realm_id  = keycloak_realm.croeer_test.id
  client_id = "plungestreak-client"

  name    = "Plungestreak"
  enabled = true

  access_type = "PUBLIC"
  valid_redirect_uris = [
    "http://localhost:3000/*"
  ]
  web_origins           = ["*"]
  standard_flow_enabled = true

  login_theme = "plungestreak-theme"

}


resource "keycloak_openid_client" "weddash_openid_client" {
  realm_id  = keycloak_realm.croeer_test.id
  client_id = "weddash-client"

  name    = "weddash"
  enabled = true

  access_type = "PUBLIC"
  valid_redirect_uris = [
    "http://localhost*",
    "https://hochzeit.roeer.net/*"
  ]
  web_origins           = ["*"]
  standard_flow_enabled = true

  login_theme = "keycloak"

}

resource "keycloak_user" "chris_user_with_initial_password" {
  realm_id = keycloak_realm.croeer_test.id
  username = "chris"
  enabled  = true

  email      = "chris@ku0.de"
  first_name = "Chris"
  last_name  = "Test"

  initial_password {
    value     = "chris"
    temporary = false
  }
}

resource "keycloak_user" "sandra_user_with_initial_password" {
  realm_id = keycloak_realm.croeer_test.id
  username = "sandra"
  enabled  = true

  email      = "sandra@ku0.de"
  first_name = "Sandra"
  last_name  = "Test"

  initial_password {
    value     = "sandra"
    temporary = false
  }
}
