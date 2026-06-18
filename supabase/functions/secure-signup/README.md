Secure Sign-up Edge Function

This Edge Function validates password strength server-side and creates a Supabase auth user using the Admin API. Deploy to Supabase Edge Functions.

Environment variables (set in Supabase Functions settings):
- SUPABASE_URL (e.g. https://xyzabc.supabase.co)
- SUPABASE_SERVICE_ROLE_KEY (service_role key from project settings)

Endpoint: POST /functions/v1/secure-signup
Body: { "email": "user@example.com", "password": "P@ssw0rd!" }

Response: 200 with user object on success; 4xx on validation errors; 5xx on server error.

Notes:
- Do NOT commit your service_role key to source control.
- Set CORS / allowed origins in your Supabase project so the app can call this function from browser.
- After creating a user via the Admin API, the function sets email_confirm=true so the user is confirmed. If you prefer email confirmation flow, set email_confirm=false and Supabase will email confirmation.
