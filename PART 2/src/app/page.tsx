import Link from "next/link";
import { redirect } from "next/navigation";
import { getSession } from "@/lib/session";

export default async function HomePage() {
  const session = await getSession();
  if (session.isLoggedIn) {
    redirect("/dashboard");
  }

  return (
    <main className="mx-auto flex min-h-screen max-w-md flex-col items-center justify-center gap-6 px-4 text-center">
      <h1 className="text-3xl font-semibold">Department Portal</h1>
      <p className="text-gray-600 dark:text-gray-400">
        View your enrollment, grades, and fee balance.
      </p>
      <div className="flex gap-4">
        <Link
          href="/login"
          className="rounded-md bg-black px-4 py-2 text-white dark:bg-white dark:text-black"
        >
          Log in
        </Link>
        <Link href="/register" className="rounded-md border px-4 py-2">
          Register
        </Link>
      </div>
    </main>
  );
}
