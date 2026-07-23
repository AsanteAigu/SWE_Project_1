"use server";

import bcrypt from "bcrypt";
import { redirect } from "next/navigation";
import pool from "@/lib/db";

export interface RegisterState {
  error?: string;
}

export async function registerAction(
  _prevState: RegisterState,
  formData: FormData
): Promise<RegisterState> {
  const studentId = String(formData.get("studentId") ?? "").trim();
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const password = String(formData.get("password") ?? "");

  if (!studentId || !email || !password) {
    return { error: "All fields are required." };
  }
  if (password.length < 8) {
    return { error: "Password must be at least 8 characters." };
  }

  const student = await pool.query(
    "select student_id from student_info where student_id = $1",
    [studentId]
  );
  if (student.rowCount === 0) {
    return { error: "No student found with that student ID." };
  }

  const existing = await pool.query(
    "select user_id from users where email = $1",
    [email]
  );
  if ((existing.rowCount ?? 0) > 0) {
    return { error: "An account with that email already exists." };
  }

  const passwordHash = await bcrypt.hash(password, 10);

  try {
    await pool.query(
      "insert into users (student_id, email, password_hash) values ($1, $2, $3)",
      [studentId, email, passwordHash]
    );
  } catch (err) {
    console.error("Failed to create user:", err);
    return { error: "Could not create account. Please try again." };
  }

  redirect("/login");
}
