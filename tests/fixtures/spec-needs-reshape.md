# Offline-First Real-Time Collaborative Editor

## Overview
Build a Google Docs-like collaborative text editor that also works offline. Multiple users can edit the same document simultaneously with real-time sync, and changes made offline are merged when the user reconnects.

## Tasks

### 1. Set up rich text editor
Use Quill.js for the editor component. Add formatting toolbar.

### 2. Add real-time sync
Use WebSockets to sync changes between users in real-time. When one user types, all other users see the changes immediately.

### 3. Add offline support
Use Service Worker to cache the editor and document data. When offline, users can continue editing. Changes are stored in IndexedDB.

### 4. Merge offline changes
When the user comes back online, merge their offline changes with the server version. Handle conflicts automatically.

### 5. Add presence indicators
Show who else is currently editing the document. Display their cursor position and selection.

### 6. Add version history
Save versions of the document. Users can view and restore previous versions.

## Technical Details
- Frontend: React + Quill.js
- Backend: Node.js + Express
- Database: PostgreSQL for documents
- Real-time: Socket.io

## Success Criteria
- Multiple users can edit simultaneously
- Works offline
- Offline changes merge seamlessly
- Version history available
