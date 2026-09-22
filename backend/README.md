# MyIdealBody AI backend

FastAPI service for photo-based meal estimation. The bundled version runs fully offline with a deterministic mock recognizer, so the Android app can be developed before a vision provider or production nutrition dataset is chosen.

## Safety boundary

The vision provider may return only a catalog food ID, estimated grams, and confidence. It cannot supply nutrient values. The server calculates calories and macros from a versioned nutrition catalog and returns ranges rather than false precision.

The bundled 25-food catalog is visibly marked as **approximate demo data**. It is not suitable for medical decisions or production nutrition claims. For production, normalize and validate records from:

- TKPI only after obtaining permission appropriate to the intended commercial use; and/or
- USDA FoodData Central records under CC0.

Preserve dataset, source record ID, license, and retrieval date in every production record's `provenance` object. Set `NUTRITION_CATALOG_PATH` to the resulting normalized JSON file. The server validates it at startup.

Production mode is intentionally fail-closed. With `APP_ENV=production`, startup is refused if any of these are true:

- `DEBUG=true`;
- `VISION_PROVIDER=mock`;
- the active catalog is marked as approximate demo data;
- any food lacks `provenance`; or
- an external VLM uses plain HTTP.

Use HTTPS for an external VLM. A narrowly scoped escape hatch exists for a VLM reachable only through loopback, an RFC1918/link-local IP, or a `.local`/`.internal` hostname: set `ALLOW_INSECURE_PRIVATE_VLM_HTTP=true`. The override is rejected for public hosts and should be used only on a trusted private network.

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
cp .env.example .env
uvicorn app.main:app --reload --env-file .env
```

Environment variables are read directly by the process. A `.env` file requires your process manager, Docker Compose, or a dotenv launcher to load it; this service deliberately does not silently load local secrets.

Run tests:

```bash
pytest -q
```

Run in Docker:

```bash
docker build -t myidealbody-api .
docker run --rm -p 8000:8000 myidealbody-api
```

## API

### `GET /health`

Returns service version and active provider.

### `POST /v1/analyze`

Multipart fields:

- `image`: JPEG, PNG, or WebP, at most 10 MiB by default
- `locale`: `en` or `id` (default `en`)
- `source`: `camera` or `gallery` (default `camera`)

Example:

```bash
curl -X POST http://localhost:8000/v1/analyze \
  -F image=@meal.jpg \
  -F locale=id \
  -F source=camera
```

The response contains per-food and total calorie/protein/carbohydrate/fat estimates as `min`, `max`, and `estimated`, a confidence score, caveats, and relevant questions for portion size or hidden oil, santan, and sugar.

`MAX_REQUEST_BODY_BYTES` (11 MiB by default) protects the full multipart request. The ASGI middleware rejects an oversized declared `Content-Length` before Starlette's multipart parser can spool the upload, and also counts streamed chunks when the header is missing or false. Keep a matching or smaller hard body limit at the public ingress/reverse proxy as defense in depth; application middleware cannot replace connection-level limits and timeouts.

The default `mock` provider does **not** inspect the photo; it always returns a development plate of rice, fried chicken, and vegetables. This is explicit in the response as `provider: "mock_demo"`.

## Vision provider

Set `VISION_PROVIDER=openai_compatible` plus the URL/model/key variables in `.env.example`. The adapter:

1. validates and resizes the image to at most 1600 × 1600;
2. requests only catalog IDs, grams, and confidence;
3. rejects unknown IDs and any extra fields, including provider-supplied nutrients; and
4. uses the server catalog for every nutrition calculation.

The endpoint URL is server configuration, never user input. Before production, confirm the selected provider's privacy terms, regional processing, retention controls, throughput, and observed accuracy on Indonesian meals.

## Google Play verification skeleton

`POST /v1/billing/google/verify` is disabled by default. When enabled, it uses the Android Publisher `subscriptionsv2` read endpoint, fixes the package name server-side, allowlists product IDs, redacts purchase tokens through Pydantic `SecretStr`, and never stores the token.

This endpoint currently accepts an **internal server bearer token**. Do not embed that token in an APK. It is a secure-by-default integration skeleton, not final consumer authentication. Before launch, put verification behind an authenticated user session (and preferably Play Integrity/App Check), bind purchases to your user records, handle real-time developer notifications, implement idempotent entitlement updates, and add rate limiting/audit logs that never include purchase tokens.

Expected product IDs:

- `myidealbody_pro_monthly`
- `myidealbody_pro_annual`

Google Play Console remains the source of truth for localized pricing. The app should show `ProductDetails.price`; it should not hardcode rupiah or dollar strings.

## Production checklist

- Replace the mock recognizer and run a labeled Indonesian-food accuracy benchmark.
- Replace demo nutrients with licensed/provenanced records and human review.
- Add user authentication, per-user authorization, rate limiting, and abuse controls.
- Set a hard request-body limit and slow-upload timeout at the public ingress.
- Store only the minimum diary data needed; this API currently keeps uploads in memory and does not persist images.
- Obtain consent before sending images to an external VLM and document retention/deletion.
- Add observability without images, purchase tokens, authorization headers, or other sensitive payloads.
- Terminate TLS at a trusted ingress and restrict CORS to actual web origins if a web client is shipped.
- Verify purchases and acknowledgements on the server; implement Play real-time developer notifications.
- Complete Google Play Data safety, Health apps, account deletion, and privacy-policy requirements.
