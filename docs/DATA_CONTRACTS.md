# Data Contracts

Last updated: 2026-05-20.

This document describes the Firestore shapes currently used by the Flutter app.
It is not a replacement for `firestore.rules`; update both when contracts change.

## users/{uid}

Mapped by `lib/core/models/user_model.dart`.

Fields:

- `uid`: string
- `username`: string
- `usernameLower`: string, normalized username for uniqueness query
- `fullName`: string
- `email`: string
- `phone`: string
- `displayName`: string
- `bio`: string
- `avatarUrl`: string
- `websiteUrl`: string
- `followersCount`: number
- `followingCount`: number
- `newsCount`: number
- `role`: string
- `interests`: string array
- `roleDetails`: map
- `onboardingCompleted`: boolean
- `updatedAt`: server timestamp
- `fcmTokens`: string array, written by notification token sync

Role ids:

- `student`
- `founder`
- `mentor`
- `investor`
- `college`
- `startup_enthusiast`

Role details are stored as a flexible map. Current app field keys include:

- Student: `state`, `collegeName`, `degreeCourse`, `year`, `branch`, `skills`, `lookingFor`
- Founder: `startupName`, `startupStage`, `industry`, `startupDescription`, `businessNeeds`, `startupLocation`, `teamSize`
- Mentor: `profession`, `company`, `expertise`, `yearsExperience`, `industry`, `mentorshipArea`, `availability`
- Investor: `investorType`, `firmName`, `investmentRange`, `preferredIndustries`, `preferredStage`, `portfolioCompanies`
- College: `cityState`, `collegeName`, `collegeType`, `contactPersonName`, `designation`, `numberOfStudents`, `interestedIn`
- Startup enthusiast: `interestArea`, `lookingFor`

Values are stored as plain strings. Many keys are entered through dropdowns in
the fill/edit profile screens (single source of truth:
`core/config/profile_field_options.dart`), but the stored value is still just
the selected/typed string.

Fixed dropdowns (no free text):

- `year` — `1st Year`…`4th Year`, `Graduated` (student)
- `startupStage` — Idea, MVP, Early Revenue, Growth/Scaling, Profitable (founder)
- `teamSize` — Solo, 2–5, 6–10, 11–25, 26–50, 50+ (founder)
- `yearsExperience` — 0–2, 3–5, 6–10, 11–15, 16+ (mentor)
- `availability` — Free, Paid, Group sessions (mentor)
- `investorType` — Angel, VC, Micro VC, Family Office, Syndicate, Corporate
- `investmentRange` — <₹10L, ₹10L–50L, ₹50L–1Cr, ₹1Cr–5Cr, ₹5Cr+ (investor)
- `preferredStage` — Pre-Seed, Seed, Series A, Series B+, Growth (investor)
- `collegeType` — Engineering, Management, University, Arts & Science, Medical,
  Polytechnic (college)
- `numberOfStudents` — <500, 500–1K, 1K–5K, 5K–10K, 10K+ (college)

Dropdown + "Other" free-text option:

- `branch` — CSE, IT, AIML, Data Science, Mechanical, Civil, EEE, ECE (student)
- `degreeCourse` — common Indian degrees (student)
- `lookingFor` — Internship, Co-founder, Networking, Learning, Job (student /
  startup enthusiast)
- `businessNeeds` — Funding, Mentors, Hiring, Co-founder, Partnerships (founder)
- `designation` — Placement Officer, Dean, Director, Professor, HoD, Incubation
  Manager (college)
- `state` / `location` / `startupLocation` / `cityState` — Indian states &
  union territories (student college state, shared About-section location,
  founder, college)

Special field:

- `collegeName` (student & college roles) — entered through a state-filtered
  searchable picker backed by a **bundled app asset**
  (`assets/data/colleges_in.json`, built from the AISHE dataset), not Firestore,
  with an "Other" free-text fallback. The state filter uses the role's own state
  field: `state` for students, `cityState` for the college role.

Fields saved before a key became a dropdown (or values entered via "Other")
are preserved as-is and shown as custom entries. Note: `teamSize`,
`yearsExperience`, and `numberOfStudents` now store range labels (e.g. `2–5`)
rather than raw numbers.

## College list (bundled asset, not Firestore)

The college picker reads a bundled asset rather than a Firestore collection, so
it needs no reads/writes and works offline.

- Asset: `assets/data/colleges_in.json`
- Shape: `{ "<Canonical State>": ["College name", ...], ... }` — names are
  de-duplicated and alphabetically sorted; state keys use the app's canonical
  labels so the picker's state filter matches.
- Built by `scripts/build_colleges_asset.py` from the government AISHE dataset
  (~43k colleges; Government Open Data License – India, attribution required).
- Loaded/searched by `CollegeRepository` (in-memory substring search). To
  refresh the list, re-run the builder and ship an app update.

## users/{uid}/communities/{communityId}

Membership index for the user's joined communities.

Fields:

- `joinedAt`: server timestamp
- `lastReadAnnouncementAt`: server timestamp

Used for My Groups and unread announcement badges.

## users/{uid}/notifications/{notificationId}

Per-user app notifications. Repository expects:

- notification fields defined by `AppNotification`
- `createdAt`
- `isRead`

The route `/notifications` reads from this collection.

## user_topics/{uid}

Fields:

- `topics`: string array
- `updatedAt`: server timestamp

Written best-effort after onboarding interests are selected.

## articles/{articleId}

Mapped by `NewsArticleModel`.

Common fields used by the app:

- `authorId`
- `category`
- `headline`
- `sourceName`
- `sourceId`
- `sourceLogoAsset`
- `thumbnailAsset`
- `featuredImageUrl`, optional single featured image for detail pages; falls back to `thumbnailAsset`
- `body`
- `timeAgo`
- `createdAt`
- `updatedAt`
- `likesCount`
- `commentsCount`
- `likedBy`: string array
- `bookmarkedBy`: string array
- `isTrending`
- `isSourceFollowing`
- `imageGallery`: string array, rendered in the middle of article detail content

Interactions:

- `likedBy` and `likesCount` are updated in a transaction.
- `bookmarkedBy` is updated by array union/remove.

Read/query behavior:

- Initial latest feed reads are limited to 20 articles ordered by `updatedAt`
  descending.
- Category feeds query `category` with common case variants of the requested
  category ordered by `updatedAt` descending. Migration should still normalize
  categories to lowercase going forward.
- Trending feeds query `isTrending == true` ordered by `updatedAt` descending.
- View-all section pages use cursor pagination with the last Firestore document
  snapshot and the same `updatedAt` ordering.
- Migration/import code should populate `updatedAt` for every article, because
  Firestore `orderBy('updatedAt')` excludes documents where the field is
  missing.

Indexes likely needed in Firestore:

- `articles`: `category` ascending, `updatedAt` descending
- `articles`: `isTrending` ascending, `updatedAt` descending
- `articles`: `authorId` ascending, `updatedAt` descending
- `articles`: `bookmarkedBy` array, `updatedAt` descending
- `articles`: `likedBy` array, `updatedAt` descending

## articles/{articleId}/comments/{commentId}

Article comments use `CommentModel` from `post_model.dart`.

Fields:

- `userId`
- `authorName`
- `avatarUrl`
- `content`
- `createdAt`

Current repository adds article comments but does not increment article
`commentsCount` in the same method.

## posts/{postId}

Mapped by `PostModel` for Explore/media feed.

Fields:

- `authorId`
- `authorName`
- `authorRole`
- `authorAvatarUrl`
- `headline`
- `excerpt`
- `category`
- `mediaType`
- `videoUrl`
- `thumbnailUrl`
- `likedBy`: string array
- `likesCount`
- `bookmarkedBy`: string array
- `commentsCount`
- `shareCount`
- `isTrending`
- `createdAt`

Interactions:

- likes update `likedBy` and `likesCount`
- bookmarks update `bookmarkedBy`
- shares increment `shareCount`

Rules note: `firestore.rules` currently allow `sharesCount`, but code writes
`shareCount`. Align this before relying on non-admin share increments.

## posts/{postId}/comments/{commentId}

Fields:

- `userId`
- `authorName`
- `avatarUrl`
- `content`
- `createdAt`

Adding a post comment increments `posts/{postId}.commentsCount`.

## communities/{communityId}

Mapped by `CommunityModel`.

Fields:

- `name`
- `description`
- `emoji`
- `colorHex`
- `memberCount`
- `createdAt`
- `lastPost`
- `lastAnnouncementAt`
- `isDefault`, for seeded communities

Default seed ids:

- `founders-network-india`
- `ai-founders-club`
- `investors-mentors`
- `mentorship-hub`

Defaults are only seeded if the `communities` collection is empty.

## communities/{communityId}/members/{uid}

Fields:

- `userId`
- `displayName`
- `avatarUrl`
- `email`
- `role`
- `interests`
- `joinedAt`

Joining also increments community `memberCount` and writes the user membership
index.

## communities/{communityId}/announcements/{postId}

Mapped by `CommunityPostModel`.

Fields:

- `content`
- `authorId`
- `authorName`
- `authorAvatarUrl`
- `authorRole`
- `type`: `announcement`, `event`, or `system`
- `createdAt`
- `imageUrl`
- `linkUrl`
- `linkTitle`
- `linkDescription`
- `commentCount`

Normal announcements should be created by admin tooling. The mobile app creates
`system` posts when a user joins.

Link behavior:

- `linkUrl` is opened externally in browser.
- `linkTitle` and `linkDescription` are displayed as preview metadata when present.

## communities/{communityId}/announcements/{postId}/comments/{commentId}

Mapped by `CommunityCommentModel`.

Fields:

- `postId`
- `communityId`
- `content`
- `authorId`
- `authorName`
- `authorAvatarUrl`
- `authorRole`
- `createdAt`
- `replyToCommentId`
- `replyToAuthorName`
- `mentionedUserIds`: string array
- `reportCount`
- `reportedBy`: string array
- `status`: `visible`, `reported`, or `deleted`
- `isAdminReply`: boolean

Activity depends on collection group queries for these comment docs.

Admin replies and mentions:

- To notify/show a reply in My Activity, set `mentionedUserIds` to include the target user uid.
- The app also checks `@displayName` in content as a fallback, but that is not reliable for targeted notifications.

## reports/{reportId}

Fields validated by rules:

- `reportedBy`
- `type`: `article` or `comment`
- `reason`: `spam`, `misinformation`, `harassment`, or `other`
- `targetId`
- `articleId`

Reports are immutable for clients after creation.

## Rules Notes

Important rule facts:

- Admin UID is hardcoded in `firestore.rules`.
- `articles` are publicly readable; create/update/delete are admin-only.
- `users` are readable by signed-in users; owner/admin can write.
- `communities` are publicly readable; normal users can only update limited fields for join/leave.
- `announcements` are readable by signed-in users; normal users can create only self-authored `system` posts.
- Announcement comments are signed-in readable/creatable; report fields can be updated by signed-in users; deletes are admin-only.
- Recursive `match /{path=**}/comments/{commentId}` enables signed-in collection group reads for activity.

Known rule risks:

- The nested `match /comments/{commentId}` inside `articles/{articleId}/comments/{commentId}` looks accidental and should be reviewed.
- Media post rule field name `sharesCount` does not match code field `shareCount`.
- Admin identity should eventually move away from a single hardcoded UID.
