export default function Footer() {
  // ⬇️ PASTE YOUR REAL iubenda LINKS HERE WHEN READY (for now, placeholders)
  const PRIVACY_POLICY_URL =
    "https://www.iubenda.com/privacy-policy/REPLACE_ME";
  const TERMS_URL = "https://www.iubenda.com/terms-and-conditions/REPLACE_ME";

  return (
    <footer className="border-t border-slate-800 bg-slate-950 text-slate-400">
      <div className="mx-auto max-w-6xl px-6 py-10">
        <div className="flex flex-col items-center gap-6 sm:flex-row sm:justify-between">
          {/* Brand */}
          <div className="flex flex-col items-center gap-1 sm:items-start">
            <span className="text-lg font-semibold tracking-tight text-white">
              LEQVOR<span className="text-emerald-400">.</span>
            </span>
            <p className="text-xs text-slate-500">
              Your data, encrypted end-to-end. Always.
            </p>
          </div>

          {/* Legal links */}
          <nav className="flex items-center gap-6 text-xs">
            <a
              href={PRIVACY_POLICY_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="transition-colors hover:text-white"
            >
              Privacy Policy
            </a>
            <span className="h-3 w-px bg-slate-700" aria-hidden="true" />
            <a
              href={TERMS_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="transition-colors hover:text-white"
            >
              Terms & Conditions
            </a>
          </nav>
        </div>

        {/* Copyright */}
        <div className="mt-8 border-t border-slate-800/60 pt-6 text-center text-[11px] text-slate-600">
          © {new Date().getFullYear()} Lenvor Technologies. All rights reserved.
        </div>
      </div>
    </footer>
  );
}
