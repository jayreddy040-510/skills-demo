"use server";

export type SubmitCrypticResult =
  | { ok: true; value: string }
  | { ok: false; code: "E_X7A9"; message: string };

export async function submitCryptic(formData: FormData): Promise<SubmitCrypticResult> {
  const rawValue = formData.get("message");
  const value = typeof rawValue === "string" ? rawValue.trim() : "";

  if (!value) {
    return {
      ok: false,
      code: "E_X7A9",
      message: "E_X7A9: Null vector collapsed in lexical manifold.",
    };
  }

  return { ok: true, value };
}
