/**
 * Verify Supabase JWT (ES256 / JWT Signing Keys) inside the Edge Function.
 * Use this when the function is deployed with --no-verify-jwt so the gateway
 * does not reject requests; we enforce auth here instead.
 */
/// <reference path="./deno.d.ts" />
/// <reference path="./jose.d.ts" />
import * as jose from "jsr:@panva/jose@6";

const MISSING_URL_MESSAGE =
  "SUPABASE_URL is not set. Set it in your project's Edge Function settings.";

let cachedIssuer: string | null = null;
let cachedJwkSet: ReturnType<typeof jose.createRemoteJWKSet> | null = null;

function getJwtConfig(): {
  issuer: string;
  jwkSet: ReturnType<typeof jose.createRemoteJWKSet>;
} {
  if (cachedJwkSet !== null) {
    return { issuer: cachedIssuer!, jwkSet: cachedJwkSet };
  }
  const raw = Deno.env.get("SUPABASE_URL");
  if (!raw || !raw.trim()) {
    throw new Error(MISSING_URL_MESSAGE);
  }
  const base = raw.trim().replace(/\/$/, "");
  try {
    cachedIssuer =
      Deno.env.get("SB_JWT_ISSUER") ?? `${base}/auth/v1`;
    cachedJwkSet = jose.createRemoteJWKSet(
      new URL(`${base}/auth/v1/.well-known/jwks.json`),
    );
  } catch (e) {
    throw new Error(
      `${MISSING_URL_MESSAGE} Invalid SUPABASE_URL: ${e instanceof Error ? e.message : String(e)}`,
    );
  }
  return { issuer: cachedIssuer, jwkSet: cachedJwkSet };
}

export function getAuthToken(req: Request): string {
  const authHeader = req.headers.get("authorization");
  if (!authHeader) {
    throw new Error("Missing authorization header");
  }
  const [bearer, token] = authHeader.split(" ");
  if (bearer !== "Bearer" || !token) {
    throw new Error("Auth header must be 'Bearer <token>'");
  }
  return token;
}

export async function verifySupabaseJWT(jwt: string) {
  const { issuer, jwkSet } = getJwtConfig();
  return jose.jwtVerify(jwt, jwkSet, { issuer });
}
