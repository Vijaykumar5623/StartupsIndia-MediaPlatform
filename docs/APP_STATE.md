# App State

Last updated: 2026-05-21.

## Product Shape

The app is a startup ecosystem media and community platform. It combines a news
feed, media/explore feed, community announcements and discussions, role-based
onboarding, and a personal profile area.

The current UI is primarily dark-mode friendly. Light theme exists and is wired
through the shared theme provider.

## Entry And Auth

Current startup route is `/splash`.

Splash behavior:

- If no Firebase user exists, route to `/welcome`.
- If a Firebase user exists, read `users/{uid}.onboardingCompleted`.
- If onboarding is incomplete, route to `/role-selection`.
- If onboarding is complete or Firestore read fails, route to `/home`.

Welcome behavior:

- Login routes to `/login`.
- Create Account routes to `/role-selection`.
- Continue as Guest routes directly to `/home`.

Guest users can see app surfaces, but protected actions should use `GuestGate`
or explicit auth checks.

## Signup And Onboarding

The create-account flow is role-first:

1. Select role.
2. Create account by email/password or Google.
3. Select interests.
4. Fill profile.

Supported roles:

- `student`
- `founder`
- `mentor`
- `investor`
- `college`
- `startup_enthusiast`

Role selection is locked after signup. Role-specific fields can still be edited
later, but the role id itself is not presented as a profile setting.

Fill Profile collects shared fields:

- full name
- unique username
- email address, read-only
- phone number
- avatar image
- bio
- website

**Username is the only required field; everything else is optional.** The goal
is to get users into the app fast and let them complete details later from Edit
Profile. Specifics:

- **Username is required and unique.** It is pre-filled with the email's local
  part (before `@`), sanitized to the allowed characters (`a-z0-9_`, lowercased);
  the user can tap and change it. Validation enforces the `^[a-zA-Z0-9_]{3,24}$`
  pattern, and `isUsernameAvailable` (query on `usernameLower`) blocks duplicates
  on submit. The Identity section is therefore **not** skippable.
- All other fields are optional — no presence validators; format checks (e.g.
  phone) only run when the field is actually filled. `fullName` falls back to the
  Google/Auth `displayName` when left blank.
- The Contact, role-details, and About sections each have a per-section
  **Skip / Add** toggle that collapses them. A skipped section is excluded from
  the saved profile (its typed values, if any, are not written).
- `onboardingCompleted` is set to `true` on completion regardless of how much was
  filled, so the user is not sent back through onboarding.

No Firestore rules change was needed: user profile writes are owner-gated with no
field-level required constraints. Note: username uniqueness is an app-level check
(`usernameLower`), not a DB constraint, so it can still race under concurrent
sign-ups — see `docs/known-issues.md` (a `usernames/{usernameLower}` reservation
doc would make it atomic).

It also collects role-specific fields and stores them as
`users/{uid}.roleDetails`. The field sets were implemented from a private client
requirements file and should be treated as client-approved behavior, not copied
verbatim from the private file.

Many role-specific fields are entered through dropdowns rather than free text,
defined once in `core/config/profile_field_options.dart` and shared by both the
fill-profile and edit-profile screens via the `AppDropdownField` widget. Because
both screens resolve every field through `profileDropdownFor(key)`, adding a key
to that config turns the field into a dropdown in both places automatically.

The student role also has a `state` dropdown (Indian states/UTs) that drives a
state-filtered **college picker**: `collegeName` opens a searchable sheet backed
by a bundled app asset (`assets/data/colleges_in.json`, ~43k colleges built from
the AISHE dataset via `scripts/build_colleges_asset.py`), filtered by the chosen
state, with an "Other" free-text fallback for colleges not in the dataset. The
search runs fully offline in memory (substring match, no Firestore). The college
institution role uses the same picker for its own `collegeName`, filtered by its
`cityState` field (both roles show the state field above College Name). See
`CollegeSearchField` + `CollegeRepository`.

Fixed dropdowns (no free text): student `year`; founder `startupStage`,
`teamSize`; mentor `yearsExperience`, `availability`; investor `investorType`,
`investmentRange`, `preferredStage`; college `collegeType`, `numberOfStudents`.

Dropdown + "Other" (free-text) option: student `branch`, `degreeCourse`,
`lookingFor`; founder `businessNeeds`; college `designation`; and every location
field (`location`, `startupLocation`, `cityState`) which offers Indian states/UTs
plus "Other". Selecting a preset stores its label; "Other" stores the typed
value; existing values outside the preset list load as "Other" custom entries.

Username uniqueness is checked by querying `users.usernameLower`.
Profile handle display prefers `users.username` and falls back to the email
prefix only for older/incomplete profiles without a saved username.

Profile photo storage:

- Google sign-in can provide `FirebaseAuth.currentUser.photoURL`.
- User-selected profile images upload to Cloudinary through
  `FirestoreRepository.uploadImage`.
- The final URL is stored in `users/{uid}.avatarUrl`.

## Main App Tabs

`MainAppScaffold` owns the bottom nav with an `IndexedStack`.

- Home tab: news/articles and home content.
- Explore tab: media feed.
- Build action: opens a bottom bubble of external Startup India links,
  including Services, which opens `https://www.startupsindia.in/contact`.
- Community tab: communities overview.
- Profile tab: personal profile.

The center Build button is not a full page. It toggles an overlay menu.

## Home

Home uses Firestore articles via `FirestoreRepository`.

Main data flows:

- Home Top News: `articles` ordered by `updatedAt desc`, limited to 10.
- Home category sections: one Firestore query per category, each limited to 10.
- General latest article reads are limited to the first 20 by default.
- Trending articles: Firestore query where `isTrending == true`, ordered by
  `updatedAt desc`.
- Category articles: Firestore query where `category` matches common case
  variants of the category, ordered by `updatedAt desc`.
- View-all article/category pages use cursor pagination and load 20 articles at
  a time.
- Article search: loads latest 100 articles and filters locally by headline, source, or category.
- Likes and bookmarks update arrays on `articles/{articleId}`.
- Article comments are stored in `articles/{articleId}/comments`.
- Reports are written to `reports`.
- Guest users can preview the first three cards in each article/podcast
  section. Remaining home and section-list cards stay visible but blurred with a
  sign-up CTA.
- Guest users can open/read preview articles, but like, comment, and bookmark
  actions open the auth prompt instead of writing to Firestore.

Article detail:

- Featured image/video renders first.
- Gallery images render in the middle of the article body.
- Like/comment/share CTA sits after the article body.
- Related articles/podcasts render as a horizontal carousel after the CTA.
- The end of Home includes a StartupsIndia Pro upgrade CTA that routes to the
  in-app Pro screen.

## Explore

Explore has Firestore-backed media posts in `posts`.

`PostModel` supports:

- author identity
- headline/excerpt/category
- media type
- video URL
- thumbnail URL
- liked/bookmarked user arrays
- counts for likes, comments, shares
- trending flag

Post comments are stored under `posts/{postId}/comments`.

## Community

Community is now Firestore-backed.

Overview screen:

- Quick cards route to full pages for My Groups, Discover, and My Activity.
- Preview sections show a small sample and a View All route.
- Activity preview means the user's community comments and mentions.

Collection screens:

- My Groups shows joined communities.
- Discover shows all available communities in a grid.
- My Activity shows comments the user wrote and comments mentioning the user.

Community detail:

- Shows community info and membership state.
- Joined users can read announcements.
- Only admins can create normal announcements from the app/admin side.
- Users can join/leave.
- Users can comment on announcements.
- Comments are opened in a bottom sheet from the comments icon/row.
- Comments can be replied to or reported.
- Link previews in announcements open in an external browser.

Communities are not hardcoded as permanent app state. The repo seeds four
defaults only if Firestore has no community documents. New production
communities should be created in Firestore/admin tooling.

## Profile

Personal profile shows:

- identity: avatar, full name, handle, role pill, bio, interests chips
- meta row: location (from `roleDetails.location`), joined date (from Firebase
  Auth `metadata.creationTime`), website link
- StartupsIndia Pro upgrade banner
- four tabs: Overview | Activity | Groups | Bookmarks

**Overview tab** — About Me bio, role-specific detail rows (from `roleDetails`
keyed by role), role-based achievement cards.

**Activity tab** — recent activity feed (joined community, liked post,
commented on article/video, replied to community announcement). Currently
populated with dummy items; real activity indexing is planned.

**Groups tab** — communities the user has joined (same as old Communities tab).

**Bookmarks tab** — saved articles + saved explore videos in one place.

Profile does **not** show posts/followers/following counts (removed by design).

Edit profile:
- single Save button in header (bottom duplicate removed)
- email is read-only; phone is editable with live validation
- pre-filled fields validate correctly even without user interaction (fixed
  `AppTextField` FormField validator to read controller text directly)
- location field shared across all roles
- role-specific section shows role-appropriate detail fields (student college
  info, founder startup info, mentor expertise, etc.)
- dropdown-backed role fields (and the shared location field) use the same
  shared `AppDropdownField` + `profile_field_options.dart` as fill-profile; an
  existing value outside the preset list loads as an "Other" custom entry
- role cannot be changed after sign-up (locked banner shown in edit form)

Profile images upload to Cloudinary via `FirestoreRepository.uploadImage`;
URL stored in `users/{uid}.avatarUrl`.

## Notifications

Firebase Messaging is initialized in `main.dart`.

- Foreground messages show a snackbar and local notification.
- Tapping a notification with `data.page == "notifications"` routes to `/notifications`.
- FCM tokens are saved to `users/{uid}.fcmTokens` through the notifications repository.
- App notifications are stored under `users/{uid}/notifications`.
