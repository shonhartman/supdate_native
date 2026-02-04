/**
 * Verify Supabase JWT (ES256 / JWT Signing Keys) inside the Edge Function.
 * Use this when the function is deployed with --no-verify-jwt so the gateway
 * does not reject requests; we enforce auth here instead.
 */
/// <reference path="./deno.d.ts" />
/// <reference path="./jose.d.ts" />
import * as jose from "jsr:@panva/jose@6";

const SUPABASE_JWT_ISSUER =
  Deno.env.get("SB_JWT_ISSUER") ??
  `${Deno.env.get("SUPABASE_URL")}/auth/v1`;

const SUPABASE_JWT_KEYS = jose.createRemoteJWKSet(
  new URL(`${Deno.env.get("SUPABASE_URL")}/auth/v1/.well-known/jwks.json`),
);

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
  return jose.jwtVerify(jwt, SUPABASE_JWT_KEYS, {
    issuer: SUPABASE_JWT_ISSUER,
  });
}
