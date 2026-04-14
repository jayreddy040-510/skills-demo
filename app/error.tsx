"use client";

type ErrorPageProps = {
  error: Error & { digest?: string };
  reset: () => void;
};

export default function ErrorPage({ error, reset }: ErrorPageProps) {
  return (
    <div className="flex min-h-screen items-center justify-center bg-black px-6 text-zinc-100">
      <main className="w-full max-w-2xl rounded-2xl border border-red-900/60 bg-zinc-950 p-8 shadow-2xl">
        <p className="mb-3 text-xs uppercase tracking-[0.2em] text-red-400">
          Critical Frontend Fault
        </p>
        <h1 className="mb-4 text-3xl font-semibold text-red-300">
          Application Execution Halted
        </h1>
        <p className="mb-6 text-zinc-300">
          A non-recoverable runtime anomaly occurred.
        </p>
        <pre className="mb-6 overflow-x-auto rounded-lg border border-zinc-800 bg-zinc-900 p-4 text-sm text-red-200">
          {error.message}
        </pre>
        <button
          type="button"
          onClick={reset}
          className="rounded-lg bg-red-700 px-4 py-2 text-sm font-medium text-white transition hover:bg-red-600"
        >
          Attempt Recovery
        </button>
      </main>
    </div>
  );
}
