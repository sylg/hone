# Add User Avatar Upload Endpoint

## Why
Users currently can't change their profile avatar. They've been requesting this since launch.

## Tasks

### 1. Create upload endpoint
POST `/api/users/avatar` that accepts a multipart file upload. Validate file type (JPEG, PNG, WebP) and size (max 5MB). Resize to 256x256.

### 2. Store in S3
Upload the resized image to S3 bucket `app-avatars` with key `users/{userId}/avatar.{ext}`. Generate a signed URL for reading.

### 3. Update user record
Save the S3 key in `users.avatar_key` column. Return the signed URL in the API response.

### 4. Update profile page
Add an avatar upload component to the profile settings page. Show current avatar with an "Upload new" overlay on hover.

### 5. Update avatar display
Update the header nav and comment sections to show the user's custom avatar instead of the default initial-based avatar.

## Success Criteria
- Users can upload JPEG/PNG/WebP images up to 5MB
- Images are resized to 256x256
- Avatar appears in header and comments within 5 seconds of upload
