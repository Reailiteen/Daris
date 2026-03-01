# focus_flow_flutter

A new Flutter project.

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
