# Stripe Payment Integration

## Overview
Add Stripe checkout to our pricing page so users can subscribe to paid plans.

## Tasks

### 1. Add Stripe SDK
Install `@stripe/stripe-js` and `@stripe/react-stripe-js`.

### 2. Create checkout session endpoint
POST `/api/checkout` that creates a Stripe Checkout Session with the selected plan's price ID.

### 3. Redirect to Stripe Checkout
When user clicks "Subscribe", create a checkout session and redirect to Stripe's hosted checkout page.

### 4. Handle success redirect
After successful payment, Stripe redirects to `/success?session_id={CHECKOUT_SESSION_ID}`. Display a success message.

### 5. Handle webhook
Set up POST `/api/webhooks/stripe` to receive Stripe events. On `checkout.session.completed`, update the user's subscription status in the database.

### 6. Update UI
Show current plan status on the settings page. Show "Upgrade" button for free users.

## Success Criteria
- Users can subscribe to a paid plan
- Payment is processed through Stripe
- User's plan is updated in our database
