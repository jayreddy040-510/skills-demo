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
    throw new Error("E_X7A9: Null vector collapsed in lexical manifold.");
  }

  return { value };
}
