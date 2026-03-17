# Team Permissions System

## Why
As we grow beyond single-user accounts, teams need role-based access control. Enterprise customers have made this a requirement for their procurement process.

## Architecture
Role-based access control (RBAC) with three default roles: Owner, Admin, Member. Permissions are attached to roles, not individual users. A user can have different roles in different teams.

## Tasks

### 1. Database schema
Create tables: `teams`, `team_memberships` (user_id, team_id, role), `roles`, `role_permissions`. Seed default roles.

### 2. Team CRUD API
- POST `/api/teams` — create team
- GET `/api/teams/:id` — get team details
- PATCH `/api/teams/:id` — update team settings
- DELETE `/api/teams/:id` — delete team (owner only)

### 3. Membership management API
- POST `/api/teams/:id/members` — invite member
- PATCH `/api/teams/:id/members/:userId` — change role
- DELETE `/api/teams/:id/members/:userId` — remove member
- POST `/api/teams/:id/invitations` — send email invitation

### 4. Authorization middleware
Create middleware that checks the current user's role and permissions for the current team context. Apply to all team-scoped endpoints.

### 5. Team context switching
Users who belong to multiple teams need a team switcher in the header. All data is scoped to the current team context.

### 6. Invitation flow
Send invitation email with unique token. Recipient can accept/decline. Token expires after 7 days. Invitation page shows team name and inviter.

### 7. Permissions UI
Settings page where Admins can view role definitions. Owners can create custom roles with specific permission sets.

### 8. Data migration
Migrate existing single-user data into team context. Create a "Personal" team for each existing user. Ensure zero downtime during migration.

### 9. Billing integration
Team plan pricing: charge per seat. Update Stripe subscription when members are added/removed. Pro-rate mid-cycle changes.

## Success Criteria
- Users can create teams and invite members
- Role-based access control works across all endpoints
- Existing users are migrated seamlessly
- Billing reflects team size
