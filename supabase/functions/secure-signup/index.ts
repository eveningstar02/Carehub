import { serve } from 'std/server'

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, apikey',
}

serve(async (req) => {
  try {
    // Respond to preflight
    if (req.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS_HEADERS })
    }

    if (req.method !== 'POST') return new Response('Method Not Allowed', { status: 405, headers: CORS_HEADERS })

    const body = await req.json()
    const { email, password } = body

    if (!email || !password) {
      return new Response(JSON.stringify({ error: 'email and password required' }), { status: 400, headers: CORS_HEADERS })
    }

    // Basic server-side validation (same rules as client)
    const hasUpper = /[A-Z]/.test(password)
    const hasLower = /[a-z]/.test(password)
    const hasDigit = /\d/.test(password)
    const hasSpecial = /[!@#\$%\^&*(),.?":{}|<>]/.test(password)
    if (password.length < 8 || !hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      return new Response(JSON.stringify({ error: 'Password does not meet complexity requirements' }), { status: 400, headers: CORS_HEADERS })
    }

    const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
    const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    if (!SUPABASE_URL || !SERVICE_KEY) {
      return new Response(JSON.stringify({ error: 'Server not configured' }), { status: 500, headers: CORS_HEADERS })
    }

    const res = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SERVICE_KEY,
        'Authorization': `Bearer ${SERVICE_KEY}`,
      },
      body: JSON.stringify({ email, password, email_confirm: true })
    })

    const data = await res.json()
    if (!res.ok) {
      // Include body and status for easier debugging
      return new Response(JSON.stringify({ error: data, status: res.status }), { status: res.status, headers: CORS_HEADERS })
    }

    // Return created user (do not return service key)
    return new Response(JSON.stringify({ user: data }), { status: 200, headers: CORS_HEADERS })
  } catch (err) {
    // log
    console.error('secure-signup error', err)
    return new Response(JSON.stringify({ error: String(err) }), { status: 500, headers: CORS_HEADERS })
  }
})
