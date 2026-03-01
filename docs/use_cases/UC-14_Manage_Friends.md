# UC-14: Manage Friends

**Primary Actor:** User
**Scope:** Both

## Goal
Provide basic social graph management allowing users to add, accept, and remove friends.

## Trigger
User accesses the friends or social section of the app.

## Preconditions
- User is authenticated.

## Postconditions (Success)
- Friendship relationships are created, confirmed, or deleted as requested.

## Main Flow
1. User searches for another user by email/username.
2. System sends a friend request, creating a pending record in `friendships`.
3. The recipient receives a notification and can accept or decline.
4. If accepted, the relationship status is updated to active.
5. Users may remove friends or cancel pending requests.

## Data Involved
- `friendships`

## Notes
- Privacy and blocking policies may be enforced separately.
