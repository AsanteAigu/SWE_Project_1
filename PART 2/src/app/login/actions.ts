"use server";

import bcrypt from "bcrypt";
import { redirect } from "next/navigation";
import pool from "@/lib/db";
import { getSession } from "@/lib/session";

export interface LoginState {
  error?: string;
}

interface UserRow {
  user_id: number;
  student_id: string;
  password_hash: string;
}

export async function loginAction(
  _prevState: LoginState,
  formData: FormData
): Promise<LoginState> {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) {
    return { error: "Email and password are required." };
  }

  const result = await pool.query<UserRow>(
    "select user_id, student_id, password_hash from users where email = $1",
    [email]
  );

  const user = result.rows[0];
  if (!user) {
    return { error: "Invalid email or password." };
  }

  const passwordMatches = await bcrypt.compare(password, user.password_hash);
  if (!passwordMatches) {
    return { error: "Invalid email or password." };
  }

  const session = await getSession();
  session.userId = user.user_id;
  session.studentId = user.student_id;
  session.isLoggedIn = true;
  await session.save();

  redirect("/dashboard");
}
