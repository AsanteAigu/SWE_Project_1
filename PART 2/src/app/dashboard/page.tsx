import { redirect } from "next/navigation";
import pool from "@/lib/db";
import { getSession } from "@/lib/session";
import { logoutAction } from "./actions";

interface StudentInfo {
  student_id: string;
  first_name: string;
  last_name: string;
  date_of_birth: string | null;
  total_fee_due: string | null;
}

interface FeeSummary {
  total_fee_due: string | null;
  total_paid: string;
  remaining: string | null;
}

interface CourseRow {
  course_id: string;
  course_name: string;
  credits: number;
  grade: string | null;
}

function formatCurrency(value: string | number | null) {
  if (value === null) return "GHS 0.00";
  return `GHS ${Number(value).toLocaleString("en-GB", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;
}

function formatDate(value: string | null) {
  if (!value) return "—";
  return new Date(value).toLocaleDateString("en-GB", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

function initialsOf(firstName: string, lastName: string) {
  return `${firstName[0] ?? ""}${lastName[0] ?? ""}`.toUpperCase();
}

const GRADE_META: Record<string, { dot: string; label: string }> = {
  A: { dot: "var(--status-good)", label: "Excellent" },
  "A-": { dot: "var(--status-good)", label: "Excellent" },
  "B+": { dot: "var(--accent)", label: "Good" },
  B: { dot: "var(--accent)", label: "Good" },
  "B-": { dot: "var(--accent)", label: "Good" },
  "C+": { dot: "var(--status-warning)", label: "Satisfactory" },
  C: { dot: "var(--status-warning)", label: "Satisfactory" },
  "C-": { dot: "var(--status-warning)", label: "Satisfactory" },
  "D+": { dot: "#eb6834", label: "Pass" },
  D: { dot: "#eb6834", label: "Pass" },
  F: { dot: "var(--status-critical)", label: "Fail" },
};

function CheckCircleIcon({ color }: { color: string }) {
  return (
    <svg
      width="14"
      height="14"
      viewBox="0 0 24 24"
      fill="none"
      stroke={color}
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className="shrink-0"
      aria-hidden="true"
    >
      <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
      <polyline points="22 4 12 14.01 9 11.01" />
    </svg>
  );
}

function AlertTriangleIcon({ color }: { color: string }) {
  return (
    <svg
      width="14"
      height="14"
      viewBox="0 0 24 24"
      fill="none"
      stroke={color}
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className="shrink-0"
      aria-hidden="true"
    >
      <path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z" />
      <line x1="12" y1="9" x2="12" y2="13" />
      <line x1="12" y1="17" x2="12.01" y2="17" />
    </svg>
  );
}

function WalletIcon({ color }: { color: string }) {
  return (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke={color}
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M21 12V7H5a2 2 0 0 1 0-4h14v4" />
      <path d="M3 5v14a2 2 0 0 0 2 2h16v-5" />
      <path d="M18 12a2 2 0 0 0 0 4h4v-4Z" />
    </svg>
  );
}

function UserIcon({ color }: { color: string }) {
  return (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke={color}
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
      <circle cx="12" cy="7" r="4" />
    </svg>
  );
}

function BookIcon({ color }: { color: string }) {
  return (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke={color}
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
      <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2Z" />
    </svg>
  );
}

function tint(color: string) {
  return `color-mix(in srgb, ${color} 16%, var(--surface))`;
}

function GradeBadge({ grade }: { grade: string | null }) {
  const meta = grade ? GRADE_META[grade] : undefined;
  const color = meta?.dot ?? "var(--text-muted)";
  return (
    <span
      className="inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold"
      style={{ background: tint(color), color }}
    >
      {grade ?? "In progress"}
    </span>
  );
}

function StatTile({
  label,
  value,
  tone,
  icon,
  caption,
}: {
  label: string;
  value: string;
  tone: string;
  icon: React.ReactNode;
  caption: string;
}) {
  return (
    <div
      className="rounded-xl border p-5"
      style={{ background: tint(tone), borderColor: `color-mix(in srgb, ${tone} 30%, transparent)` }}
    >
      <div className="mb-3 flex items-center gap-2">
        <span
          className="flex h-7 w-7 items-center justify-center rounded-lg"
          style={{ background: `color-mix(in srgb, ${tone} 24%, var(--surface))` }}
        >
          {icon}
        </span>
        <p className="text-xs font-semibold uppercase tracking-wide text-[var(--text-muted)]">
          {label}
        </p>
      </div>
      <p className="text-3xl font-semibold" style={{ color: tone }}>
        {value}
      </p>
      <p className="mt-1 text-xs text-[var(--text-secondary)]">{caption}</p>
    </div>
  );
}

function Card({
  title,
  icon,
  tone,
  children,
}: {
  title: string;
  icon: React.ReactNode;
  tone: string;
  children: React.ReactNode;
}) {
  return (
    <div className="rounded-xl border border-[var(--border)] bg-[var(--surface)] p-5">
      <div className="mb-4 flex items-center gap-2.5">
        <span
          className="flex h-7 w-7 items-center justify-center rounded-lg"
          style={{ background: tint(tone) }}
        >
          {icon}
        </span>
        <h2 className="text-sm font-semibold uppercase tracking-wide text-[var(--text-muted)]">
          {title}
        </h2>
      </div>
      {children}
    </div>
  );
}

export default async function DashboardPage() {
  const session = await getSession();
  if (!session.isLoggedIn) {
    redirect("/login");
  }

  const studentId = session.studentId;

  const [studentResult, feesResult, coursesResult] = await Promise.all([
    pool.query<StudentInfo>(
      `select student_id, first_name, last_name, date_of_birth, total_fee_due
       from student_info
       where student_id = $1`,
      [studentId]
    ),
    pool.query<FeeSummary>(
      `select
         s.total_fee_due,
         coalesce(sum(f.amount), 0) as total_paid,
         s.total_fee_due - coalesce(sum(f.amount), 0) as remaining
       from student_info s
       left join student_fees f on f.student_id = s.student_id
       where s.student_id = $1
       group by s.student_id, s.total_fee_due`,
      [studentId]
    ),
    pool.query<CourseRow>(
      `select c.course_id, c.course_name, c.credits, e.grade
       from enrollment e
       join courses c on c.course_id = e.course_id
       where e.student_id = $1
       order by c.course_id`,
      [studentId]
    ),
  ]);

  const student = studentResult.rows[0];
  if (!student) {
    redirect("/login");
  }

  const fees = feesResult.rows[0];
  const courses = coursesResult.rows;
  const totalCredits = courses.reduce((sum, c) => sum + c.credits, 0);

  const totalPaid = Number(fees?.total_paid ?? 0);
  const remaining = Number(fees?.remaining ?? 0);

  return (
    <main className="min-h-screen">
      <header className="border-b border-[var(--hairline)] bg-[var(--surface)]">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-6 py-4">
          <div className="flex items-center gap-3">
            <div
              className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-sm font-semibold"
              style={{ background: "var(--accent-tint)", color: "var(--accent)" }}
            >
              {initialsOf(student.first_name, student.last_name)}
            </div>
            <div>
              <p className="text-sm font-medium leading-tight">
                {student.first_name} {student.last_name}
              </p>
              <p className="text-xs text-[var(--text-muted)]">
                Student ID {student.student_id}
              </p>
            </div>
          </div>
          <form action={logoutAction}>
            <button
              type="submit"
              className="rounded-md border border-[var(--border)] px-3 py-1.5 text-sm hover:bg-[var(--accent-tint)]"
            >
              Log out
            </button>
          </form>
        </div>
      </header>

      <div className="mx-auto max-w-5xl px-6 py-8">
        <section className="mb-8">
          <h2 className="mb-3 text-xs font-semibold uppercase tracking-wide text-[var(--text-muted)]">
            Fee Summary
          </h2>
          <div className="grid gap-4 sm:grid-cols-2">
            <StatTile
              label="Total Paid"
              value={formatCurrency(totalPaid)}
              tone="var(--status-good)"
              icon={<WalletIcon color="var(--status-good)" />}
              caption="Payments received to date"
            />
            <StatTile
              label="Remaining Balance"
              value={formatCurrency(remaining)}
              tone={remaining > 0 ? "var(--status-critical)" : "var(--status-good)"}
              icon={
                remaining > 0 ? (
                  <AlertTriangleIcon color="var(--status-critical)" />
                ) : (
                  <CheckCircleIcon color="var(--status-good)" />
                )
              }
              caption={remaining > 0 ? "Balance due" : "Fully paid"}
            />
          </div>
        </section>

        <section className="grid gap-6 md:grid-cols-3">
          <div className="md:col-span-1">
            <Card title="Personal Info" icon={<UserIcon color="var(--accent)" />} tone="var(--accent)">
              <dl className="space-y-3 text-sm">
                <div>
                  <dt className="text-[var(--text-muted)]">Full name</dt>
                  <dd className="mt-0.5">
                    {student.first_name} {student.last_name}
                  </dd>
                </div>
                <div>
                  <dt className="text-[var(--text-muted)]">Student ID</dt>
                  <dd className="mt-0.5">{student.student_id}</dd>
                </div>
                <div>
                  <dt className="text-[var(--text-muted)]">Date of birth</dt>
                  <dd className="mt-0.5">{formatDate(student.date_of_birth)}</dd>
                </div>
              </dl>
            </Card>
          </div>

          <div className="md:col-span-2">
            <Card
              title={`Enrolled Courses · ${courses.length} courses · ${totalCredits} credits`}
              icon={<BookIcon color="var(--violet)" />}
              tone="var(--violet)"
            >
              {courses.length === 0 ? (
                <p className="text-sm text-[var(--text-muted)]">
                  No enrollments on record.
                </p>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-sm">
                    <thead>
                      <tr className="border-b border-[var(--hairline)] text-xs uppercase tracking-wide text-[var(--text-muted)]">
                        <th className="py-2 pr-4 font-medium">Course</th>
                        <th className="py-2 pr-4 font-medium">Name</th>
                        <th className="py-2 pr-4 font-medium">Credits</th>
                        <th className="py-2 font-medium">Grade</th>
                      </tr>
                    </thead>
                    <tbody>
                      {courses.map((course) => (
                        <tr
                          key={course.course_id}
                          className="border-b border-[var(--hairline)] last:border-0"
                        >
                          <td className="py-2.5 pr-4 font-medium">
                            {course.course_id}
                          </td>
                          <td className="py-2.5 pr-4 text-[var(--text-secondary)]">
                            {course.course_name}
                          </td>
                          <td className="py-2.5 pr-4 tabular-nums text-[var(--text-secondary)]">
                            {course.credits}
                          </td>
                          <td className="py-2.5">
                            <GradeBadge grade={course.grade} />
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </Card>
          </div>
        </section>
      </div>
    </main>
  );
}
