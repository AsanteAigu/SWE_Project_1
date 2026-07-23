import { getIronSession, type IronSession, type SessionOptions } from "iron-session";
import { cookies } from "next/headers";

export interface SessionData {
  userId: number;
  studentId: string;
  isLoggedIn: boolean;
}

const sessionOptions: SessionOptions = {
  password: process.env.SESSION_SECRET as string,
  cookieName: "dept_session",
  cookieOptions: {
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
  },
};

export function getSession(): Promise<IronSession<SessionData>> {
  if (!process.env.SESSION_SECRET) {
    throw new Error("SESSION_SECRET is not set. Add it to .env.local");
  }
  return getIronSession<SessionData>(cookies(), sessionOptions);
}
