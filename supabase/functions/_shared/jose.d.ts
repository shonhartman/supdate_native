/**
 * Type declarations for jose (JSR) so the IDE resolves the module.
 * Runtime: Deno fetches jsr:@panva/jose@6 when the Edge Function runs.
 */
declare module "jsr:@panva/jose@6" {
  export function createRemoteJWKSet(url: URL): unknown;
  export function jwtVerify(
    jwt: string,
    key: unknown,
    options?: { issuer?: string }
  ): Promise<{ payload: Record<string, unknown> }>;
}
