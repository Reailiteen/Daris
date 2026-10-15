# Daris

Daris helps students earn screen time by studying.

## Setup

This project uses [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) to load
configuration values such as the Supabase URL and anon key.

Before running the app, create a file named `.env` in the project root by copying
`.env.example` and filling in your own values:

```sh
cp .env.example .env
# edit .env to set SUPABASE_URL and SUPABASE_ANON_KEY
```

If `.env` is missing the app will still start, but Supabase initialization will use
empty strings and may fail.
# Daris

## AI configuration

Quick Study uses Fireworks' OpenAI-compatible serverless chat endpoint with
`accounts/fireworks/models/glm-5p3-flash`. Add `FIREWORKS_API_KEY`
to `.env` to enable product-mode question generation. Demo Mode is completely
offline and needs neither a key nor a network connection.

This competition build reads the key in the Flutter client for simplicity. Do
not ship that approach in production: put the Fireworks call behind an
authenticated server-side proxy so the key is never distributed to clients.
