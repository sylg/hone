# Real-Time Notifications

## Overview
Add real-time notifications so users see updates without refreshing the page.

## Architecture
Use WebSocket connection from the client to our notification service. When events occur (new comment, mention, assignment), push a notification to the relevant user's WebSocket connection.

## Tasks

### 1. Set up WebSocket server
Add a WebSocket endpoint at `/ws/notifications`. Authenticate the connection using the session token.

### 2. Implement notification delivery
When a notification-worthy event occurs, look up the target user's WebSocket connection and send the notification payload.

### 3. Client-side notification handler
Connect to the WebSocket on page load. Display incoming notifications as toast messages in the bottom-right corner. Play a notification sound.

### 4. Notification persistence
Store notifications in the `notifications` table. Mark as read when the user clicks on them. Show unread count in the header badge.

### 5. Notification preferences
Users can configure which notification types they want to receive in their settings page.

## Success Criteria
- Notifications appear in real-time without page refresh
- Notifications are persisted and can be viewed later
- Users can configure notification preferences
