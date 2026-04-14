"use client";

import { FormEvent, useState } from "react";

export default function Home() {
  const [value, setValue] = useState("");
  const [submittedValue, setSubmittedValue] = useState<string | null>(null);
  const [shouldCrash, setShouldCrash] = useState(false);

  if (shouldCrash) {
    throw new Error("E_X7A9: Null vector collapsed in lexical manifold.");
  }

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    if (!value.trim()) {
      setShouldCrash(true);
      return;
    }

    setShouldCrash(false);
    setSubmittedValue(value.trim());
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 px-6 font-sans dark:bg-black">
      <main className="w-full max-w-xl rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-950">
        <h1 className="mb-6 text-2xl font-semibold tracking-tight text-zinc-900 dark:text-zinc-100">
          Cryptic Submission Form
        </h1>
        <form className="flex flex-col gap-4" onSubmit={handleSubmit}>
          <input
            type="text"
            value={value}
            onChange={(event) => {
              setValue(event.target.value);
              if (submittedValue) {
                setSubmittedValue(null);
              }
            }}
            placeholder="Type something..."
            className="h-12 rounded-lg border border-zinc-300 px-4 text-base text-zinc-900 outline-none transition focus:border-zinc-500 dark:border-zinc-700 dark:bg-zinc-900 dark:text-zinc-100"
          />
          <button
            type="submit"
            className="h-12 rounded-lg bg-zinc-900 px-4 text-base font-medium text-white transition hover:bg-zinc-700 dark:bg-zinc-100 dark:text-zinc-900 dark:hover:bg-zinc-300"
          >
            Submit
          </button>
        </form>
        {submittedValue && (
          <div className="mt-4 rounded-lg border border-emerald-300 bg-emerald-50 px-4 py-3 text-emerald-800 dark:border-emerald-800 dark:bg-emerald-950/40 dark:text-emerald-300">
            Submission accepted: <span className="font-semibold">{submittedValue}</span>
          </div>
        )}
      </main>
    </div>
  );
}
