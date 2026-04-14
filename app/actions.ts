"use server";

export async function submitCryptic(formData: FormData) {
  const rawValue = formData.get("message");
  const value = typeof rawValue === "string" ? rawValue.trim() : "";

  if (!value) {
    console.error("[submitCryptic] empty submission detected", {
      code: "E_X7A9",
      hasMessageField: formData.has("message"),
      timestamp: new Date().toISOString(),
    });
    return {
      ok: false as const,
      error: "Please enter a message before submitting.",
    };
  }

  return {
    ok: true as const,
    value,
  };
}
