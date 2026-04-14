"use server";

export type SubmitResult =
  | { ok: true; value: string }
  | { ok: false; error: string };

export async function submitCryptic(formData: FormData): Promise<SubmitResult> {
  const rawValue = formData.get("message");
  const value = typeof rawValue === "string" ? rawValue.trim() : "";

  if (!value) {
    return { ok: false, error: "Please enter a message before submitting." };
  }

  return { ok: true, value };
}
