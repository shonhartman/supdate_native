/**
 * Minimal Deno globals for IDE type-checking.
 * Runtime: Supabase Edge Functions run on Deno.
 */
declare const Deno: {
  env: {
    get(key: string): string | undefined;
  };
};
