# "Back to app" overlay — web team spec

When a user taps a link inside the StartupsIndia mobile app that opens the
website, the app appends `?ref=app` to the URL. The website should detect this
and show a small overlay with a **"Back to app"** button that reopens the app.

## Contract (already implemented in the app)

- **Signal:** first-party links opened from the app carry the query param
  **`ref=app`** (e.g. `https://www.startupsindia.in/events?ref=app`).
- **Return link:** the button must point the browser at the app's custom scheme:
  **`startupsindia://open`**. This is registered on Android and iOS and reopens
  (or foregrounds) the app.

## What to build

1. On page load, if `ref=app` is present in the URL **or** it was seen earlier
   this session, remember it (e.g. `sessionStorage`) so the overlay persists as
   the user navigates around the site.
2. Show a fixed overlay/banner with a "Back to app" button linking to
   `startupsindia://open`. Include a dismiss (×) so it can be closed.
3. Only show it on mobile browsers (the scheme does nothing on desktop).

## Prompt to hand to the web dev team

> On startupsindia.in, detect visitors who arrived from our mobile app: the app
> adds `?ref=app` to the URL. When present (persist it in `sessionStorage` so it
> survives navigation), show a small fixed bottom banner/overlay on mobile with
> the text "Continue in the StartupsIndia app" and a **Back to app** button that
> links to `startupsindia://open`, plus a × to dismiss it for the session. Keep
> it lightweight and on-brand.

## Drop-in reference snippet

```html
<!-- Back-to-app overlay -->
<div id="back-to-app" hidden
     style="position:fixed;left:12px;right:12px;bottom:12px;z-index:9999;
            display:flex;align-items:center;gap:12px;padding:12px 16px;
            border-radius:14px;background:#111;color:#fff;
            box-shadow:0 8px 24px rgba(0,0,0,.25);font-family:system-ui,sans-serif">
  <span style="flex:1;font-size:14px">Continue in the StartupsIndia app</span>
  <a href="startupsindia://open"
     style="background:#E8341C;color:#fff;text-decoration:none;font-weight:600;
            font-size:14px;padding:8px 14px;border-radius:10px">Back to app</a>
  <button id="back-to-app-close" aria-label="Dismiss"
          style="background:none;border:0;color:#aaa;font-size:20px;cursor:pointer">&times;</button>
</div>

<script>
(function () {
  var KEY = 'fromApp';
  var params = new URLSearchParams(location.search);
  if (params.get('ref') === 'app') sessionStorage.setItem(KEY, '1');

  var isMobile = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
  var dismissed = sessionStorage.getItem('backToAppDismissed') === '1';
  if (isMobile && sessionStorage.getItem(KEY) === '1' && !dismissed) {
    var el = document.getElementById('back-to-app');
    el.hidden = false;
    document.getElementById('back-to-app-close').onclick = function () {
      el.hidden = true;
      sessionStorage.setItem('backToAppDismissed', '1');
    };
  }
})();
</script>
```

## Notes / gotchas

- If the app is not installed, tapping `startupsindia://open` does nothing on
  most browsers. That's acceptable here (these users came *from* the app, so it
  is installed). If you ever want a fallback, you can start a short timer after
  the tap and redirect to a store page if the app didn't take focus.
- The scheme only needs to reopen the app; it does not deep-link to a specific
  screen. If per-screen return is wanted later, we can extend the scheme (e.g.
  `startupsindia://open?screen=...`) and handle it in the app.
