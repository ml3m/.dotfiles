import QtQuick
import QtTest

import "../OAuth.js" as OAuth

TestCase {
  name: "SpotifyOAuthLogic"

  function test_oauthPortValidation() {
    compare(OAuth.normalizedPort(8989), 8989)
    compare(OAuth.normalizedPort(80), 8989)
    compare(OAuth.normalizedPort(70000), 8989)
  }

  function test_callbackParsing() {
    var result = OAuth.parseCallbackRequestLine(
      "GET /callback?code=mock-code%2Bvalue&state=mock-state HTTP/1.1")
    verify(result.ok)
    compare(result.code, "mock-code+value")
    compare(result.state, "mock-state")

    var rejectedPath = OAuth.parseCallbackRequestLine(
      "GET /other?code=mock-code&state=mock-state HTTP/1.1")
    verify(!rejectedPath.ok)

    var rejectedMethod = OAuth.parseCallbackRequestLine(
      "POST /callback?code=mock-code&state=mock-state HTTP/1.1")
    verify(!rejectedMethod.ok)
  }

  function test_callbackParsing_acceptsBundledClientPath() {
    var result = OAuth.parseCallbackRequestLine(
      "GET /login?code=mock-code&state=mock-state HTTP/1.1", "/login")
    verify(result.ok)
    compare(result.code, "mock-code")

    var rejectedPath = OAuth.parseCallbackRequestLine(
      "GET /callback?code=mock-code&state=mock-state HTTP/1.1", "/login")
    verify(!rejectedPath.ok)
  }

  function test_callbackErrorResponse() {
    var result = OAuth.parseCallbackRequestLine(
      "GET /callback?error=access_denied&error_description=Cancelled&state=mock-state HTTP/1.1")
    verify(!result.ok)
    compare(result.error, "Cancelled")
    compare(result.state, "mock-state")
  }

  function test_pkceGeneratorOutputParsing() {
    var verifier = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
    var challenge = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopq"
    var state = "0123456789abcdef0123456789abcdef0123456789abcdef"
    var result = OAuth.parsePkceOutput(verifier + "\t" + challenge + "\t" + state)
    verify(result.ok)
    compare(result.verifier, verifier)
    compare(result.challenge, challenge)
    compare(result.state, state)
    verify(!OAuth.parsePkceOutput("not\tvalid").ok)
  }

  // These JSON strings are mocked Spotify Accounts responses. Testing the
  // parser independently keeps authentication deterministic and offline.
  function test_mockedAuthorizationTokenResponse() {
    var response = OAuth.parseTokenResponse(200, JSON.stringify({
      access_token: "mock-access",
      refresh_token: "mock-refresh",
      expires_in: 3600,
      scope: "user-read-private"
    }), "")

    verify(response.ok)
    compare(response.accessToken, "mock-access")
    compare(response.refreshToken, "mock-refresh")
    compare(response.expiresIn, 3600)
  }

  function test_mockedRefreshResponseRetainsRotatingSecret() {
    var response = OAuth.parseTokenResponse(200, JSON.stringify({
      access_token: "replacement-access",
      expires_in: 1200
    }), "previous-refresh")

    verify(response.ok)
    compare(response.refreshToken, "previous-refresh")
    compare(response.expiresIn, 1200)
  }

  function test_mockedInvalidGrantResponse() {
    var response = OAuth.parseTokenResponse(400, JSON.stringify({
      error: "invalid_grant",
      error_description: "Refresh token revoked"
    }), "expired-refresh")

    verify(!response.ok)
    verify(response.invalidGrant)
    compare(response.error, "Refresh token revoked")
  }

  function test_browserResponsesDoNotEchoCredentials() {
    var success = OAuth.successResponse()
    var failure = OAuth.failureResponse()
    verify(success.indexOf("200 OK") > 0)
    verify(failure.indexOf("400 Bad Request") > 0)
    verify(success.toLowerCase().indexOf("token") === -1)
    verify(failure.toLowerCase().indexOf("token") === -1)
  }
}
