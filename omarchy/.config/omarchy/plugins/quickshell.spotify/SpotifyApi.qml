import QtQuick

import "Api.js" as Api

// Thin authenticated transport. It performs no polling and owns only one
// special request: search, which is cancelled whenever a newer query arrives.
// Requests share a small in-flight cap and a Retry-After cooldown so a
// development-mode app does not burst into Spotify's 429 window. After a
// 429, only one request goes out until a later call succeeds.
Item {
  id: root

  visible: false
  width: 0
  height: 0

  required property var auth

  property var searchRequest: null
  property int searchSerial: 0
  property var requestQueue: []
  property int requestsInFlight: 0
  property double rateLimitedUntil: 0
  property bool restrictInFlight: false
  property bool pumpingRequests: false
  property bool pumpAgain: false

  function abortRequest(handle) {
    if (!handle || handle.aborted) return
    handle.aborted = true
    var xhr = handle.xhr
    handle.xhr = null
    if (xhr && xhr.abort) xhr.abort()
    releaseRequestSlot(handle)
  }

  function requestError(status, payload, xhr, fallback) {
    if (status === 429)
      return Api.rateLimitMessage(Api.responseRetryAfter(xhr))
    return Api.responseError(status, payload, fallback)
  }

  function enqueueJob(job, preferFront) {
    requestQueue = Api.enqueueApiJob(requestQueue, job, preferFront)
    pumpRequests()
    return job.handle
  }

  function releaseRequestSlot(handle) {
    if (handle && handle.slotOpen !== true) return
    if (handle) handle.slotOpen = false
    requestsInFlight = Math.max(0, requestsInFlight - 1)
    pumpRequests()
  }

  function pumpRequests() {
    if (pumpingRequests) {
      pumpAgain = true
      return
    }
    pumpingRequests = true
    pumpAgain = false
    while (requestsInFlight < Api.apiInFlightLimit(restrictInFlight)) {
      var wait = Api.apiCooldownMs(Date.now(), rateLimitedUntil)
      if (wait > 0) {
        rateLimitTimer.interval = Math.max(50, wait)
        rateLimitTimer.restart()
        break
      }
      var taken = Api.dequeueApiJob(requestQueue)
      requestQueue = taken.queue
      if (!taken.job) break
      taken.job.handle.slotOpen = true
      requestsInFlight += 1
      startJob(taken.job)
    }
    pumpingRequests = false
    if (pumpAgain) pumpRequests()
  }

  function startJob(job) {
    var handle = job.handle
    var url = Api.safeApiUrl(job.path)
    if (!url) {
      if (typeof job.callback === "function")
        callbackIfCurrent(job, 0, null, "Something went wrong while contacting Spotify", null)
      releaseRequestSlot(handle)
      return
    }
    url = Api.appendQuery(url, job.query)

    auth.withAccessToken(function(token, tokenError) {
      if (handle.aborted) {
        releaseRequestSlot(handle)
        return
      }
      if (!token) {
        callbackIfCurrent(job, 0, null, tokenError || "Not logged in", null)
        releaseRequestSlot(handle)
        return
      }
      var xhr = new XMLHttpRequest()
      handle.xhr = xhr
      xhr.onreadystatechange = function() {
        if (xhr.readyState !== XMLHttpRequest.DONE) return
        if (handle.xhr === xhr) handle.xhr = null
        if (handle.aborted) {
          releaseRequestSlot(handle)
          return
        }
        var payload = Api.parseJson(xhr.responseText, null)
        if (xhr.status === 401 && job.retried !== true) {
          auth.invalidateAccessToken()
          job.retried = true
          requestQueue = Api.enqueueApiJob(requestQueue, job, true)
          releaseRequestSlot(handle)
          return
        }
        if (xhr.status === 429) {
          restrictInFlight = true
          rateLimitedUntil = Api.nextRateLimitedUntil(Date.now(),
            Api.responseRetryAfter(xhr), rateLimitedUntil, job.rateLimitRetries)
          if (Api.shouldRetryRateLimit(job.rateLimitRetries)) {
            job.rateLimitRetries += 1
            requestQueue = Api.enqueueApiJob(requestQueue, job, true)
            releaseRequestSlot(handle)
            return
          }
        } else {
          restrictInFlight = false
        }
        var ok = xhr.status >= 200 && xhr.status < 300
        var error = ok ? "" : root.requestError(xhr.status, payload, xhr,
          "Spotify could not complete this request")
        callbackIfCurrent(job, xhr.status, payload, error, xhr)
        releaseRequestSlot(handle)
      }
      xhr.open(String(job.method || "GET"), url)
      xhr.setRequestHeader("Authorization", "Bearer " + token)
      if (job.body !== undefined && job.body !== null) {
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.send(JSON.stringify(job.body))
      } else {
        xhr.send()
      }
    })
  }

  function callbackIfCurrent(job, status, payload, error, xhr) {
    if (typeof job.callback === "function")
      job.callback(status, payload, error, xhr)
  }

  function request(method, path, query, body, callback, retried, existingHandle) {
    var handle = existingHandle || { aborted: false, xhr: null }
    return enqueueJob({
      method: method,
      path: path,
      query: query,
      body: body,
      callback: callback,
      retried: retried === true,
      rateLimitRetries: 0,
      handle: handle
    }, retried === true)
  }

  function cancelSearch() {
    searchSerial++
    abortRequest(searchRequest)
    searchRequest = null
  }

  // Search still uses its own serial so a newer query can reject a stale
  // callback created while a token refresh is still in flight.
  function search(query, callback) {
    cancelSearch()
    var serial = searchSerial
    var term = String(query || "").trim()
    if (!term) {
      if (typeof callback === "function") callback(Api.searchGroups({}, 128), "")
      return
    }
    searchRequest = request("GET", "/search", {
      q: term,
      type: Api.SEARCH_TYPES.join(","),
      limit: 10
    }, null, function(status, payload, error) {
      if (serial !== root.searchSerial) return
      if (typeof callback !== "function") return
      if (error) callback(Api.searchGroups({}, 128), error)
      else callback(Api.searchGroups(payload, 128), "")
    })
  }

  Timer {
    id: rateLimitTimer
    repeat: false
    onTriggered: root.pumpRequests()
  }
}
