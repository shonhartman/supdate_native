/**
 * Minimal Deno globals for IDE type-checking.
 * Runtime: Supabase Edge Functions run on Deno.
 */
declare const Deno: {
  env: {
    get(key: string): string | undefined;
  };
  serve(
    handler: (req: Request) => Response | Promise<Response>,
    options?: { port?: number; hostname?: string }
  ): void;
};
