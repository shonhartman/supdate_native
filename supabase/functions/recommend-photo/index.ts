import { corsHeaders } from "../_shared/cors.ts";
import { getAuthToken, verifySupabaseJWT } from "../_shared/jwt.ts";

interface RequestBody {
  images: string[];
}

interface Recommendation {
  recommendedIndex: number;
  caption: string;
  vibe: string;
}

interface GeminiGenerateContentResponse {
  candidates?: Array<{
    finishReason?: string;
    content?: { parts?: Array<{ text?: string }> };
  }>;
}

const GEMINI_MODEL = "gemini-2.5-flash";
const GEMINI_API_BASE = "https://generativelanguage.googleapis.com/v1beta";

function buildGeminiParts(images: string[]): Record<string, unknown>[] {
  const parts: Record<string, unknown>[] = [
    {
      text: `You are a photo curator. The user has uploaded ${images.length} photos (in order: image 0, image 1, ... image ${images.length - 1}).

Choose the single best photo for a social post: most visually appealing, well-composed, and engaging. Consider lighting, focus, and subject.

Reply with valid JSON only, no markdown or extra text, in this exact shape:
{"recommendedIndex": <0-based index 0 to ${images.length - 1}>, "caption": "<short caption for the chosen photo>", "vibe": "<one short phrase describing the mood or vibe>"}`,
    },
  ];
  for (const base64 of images) {
    parts.push({
      inlineData: {
        mimeType: "image/jpeg",
        data: base64,
      },
    });
  }
  return parts;
}

async function callGemini(apiKey: string, images: string[]): Promise<Recommendation> {
  const url = `${GEMINI_API_BASE}/models/${GEMINI_MODEL}:generateContent?key=${encodeURIComponent(apiKey)}`;
  const body = {
    contents: [{ role: "user", parts: buildGeminiParts(images) }],
    generationConfig: {
      responseMimeType: "application/json",
      temperature: 0.4,
      maxOutputTokens: 2048,
    },
  };

  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Gemini API error ${res.status}: ${errText}`);
  }

  const data = (await res.json()) as GeminiGenerateContentResponse;
  const candidate = data.candidates?.[0];
  const finishReason = candidate?.finishReason ?? "(none)";

  let text =
    candidate?.content?.parts?.[0]?.text?.trim();
  if (!text) {
    console.error("[recommend-photo] Gemini no text, finishReason:", finishReason);
    throw new Error("Gemini returned no text");
  }

  // Gemini sometimes wraps JSON in markdown code fences; strip them for reliable parse
  const codeBlockMatch = /^```(?:json)?\s*\n?([\s\S]*?)\n?```$/m.exec(text);
  if (codeBlockMatch) {
    text = codeBlockMatch[1].trim();
  }
  // If there’s leading non-JSON (e.g. "Here is the JSON:\n"), start at the first {
  const firstBrace = text.indexOf("{");
  if (firstBrace > 0) {
    text = text.slice(firstBrace);
  }

  let parsed: Recommendation;
  try {
    parsed = JSON.parse(text) as Recommendation;
  } catch (parseErr) {
    console.error("[recommend-photo] Gemini invalid JSON, finishReason:", finishReason, "length:", text.length);
    throw new Error(
      `Gemini returned invalid JSON: ${parseErr instanceof Error ? parseErr.message : String(parseErr)}. Response length: ${text.length}`
    );
  }
  if (typeof parsed.caption !== "string" || typeof parsed.vibe !== "string") {
    throw new Error("Gemini response missing required fields");
  }
  const rawIndex = parsed.recommendedIndex;
  const indexNum = typeof rawIndex === "number" ? rawIndex : Number(rawIndex);
  if (!Number.isFinite(indexNum)) {
    throw new Error("Gemini response missing required fields");
  }
  const maxIndex = images.length - 1;
  const index = Math.max(0, Math.min(maxIndex, Math.floor(indexNum)));
  return {
    recommendedIndex: index,
    caption: String(parsed.caption).slice(0, 500),
    vibe: String(parsed.vibe).slice(0, 200),
  };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const token = getAuthToken(req);
    await verifySupabaseJWT(token);
  } catch {
    return new Response(
      JSON.stringify({ error: "Unauthorized. Sign in and try again." }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 401,
      },
    );
  }

  try {
    const body = (await req.json()) as RequestBody;
    const images = body?.images;

    if (!Array.isArray(images) || images.length < 2 || images.length > 10) {
      return new Response(
        JSON.stringify({
          error: "Please provide between 2 and 10 images (base64 strings).",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        }
      );
    }

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "GEMINI_API_KEY is not configured." }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 500,
        }
      );
    }

    const recommendation = await callGemini(apiKey, images);

    return new Response(JSON.stringify(recommendation), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (err) {
    return new Response(
      JSON.stringify({
        error: err instanceof Error ? err.message : "Unknown error",
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
