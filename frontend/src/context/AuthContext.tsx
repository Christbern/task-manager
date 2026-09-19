import { createContext, useContext, useState, type ReactNode } from "react";
import { api } from "@/lib/api";
import type { AuthResponse, User } from "@/types/task";

interface AuthContextValue {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  register: (fullName: string, email: string, password: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

function loadStoredUser(): User | null {
  const raw = localStorage.getItem("user");
  return raw ? (JSON.parse(raw) as User) : null;
}

function persistAuth(data: AuthResponse): User {
  localStorage.setItem("token", data.token);
  const user: User = { userId: data.userId, fullName: data.fullName, email: data.email };
  localStorage.setItem("user", JSON.stringify(user));
  return user;
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(loadStoredUser());

  async function login(email: string, password: string) {
    const { data } = await api.post<AuthResponse>("/api/auth/login", { email, password });
    setUser(persistAuth(data));
  }

  async function register(fullName: string, email: string, password: string) {
    const { data } = await api.post<AuthResponse>("/api/auth/register", {
      fullName,
      email,
      password,
    });
    setUser(persistAuth(data));
  }

  function logout() {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    setUser(null);
  }

  return (
    <AuthContext.Provider value={{ user, login, register, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth doit être utilisé à l'intérieur de <AuthProvider>");
  return ctx;
}
