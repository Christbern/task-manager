import { useState, type FormEvent } from "react";
import { Link, useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import { Sparkles } from "lucide-react";
import { useAuth } from "@/context/AuthContext";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await login(email, password);
      navigate("/tasks");
    } catch (err: any) {
      setError(err.response?.data?.message ?? "Échec de la connexion");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden bg-slate-950 px-4">
      {/* Halo de dégradé animé en fond */}
      <motion.div
        className="absolute -top-40 left-1/2 h-[32rem] w-[32rem] -translate-x-1/2 rounded-full bg-gradient-to-br from-brand-from to-brand-to opacity-30 blur-[100px]"
        animate={{ scale: [1, 1.15, 1], opacity: [0.3, 0.4, 0.3] }}
        transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
      />

      <motion.div
        initial={{ opacity: 0, y: 16 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, ease: "easeOut" }}
        className="relative z-10 w-full max-w-sm rounded-2xl border border-white/10 bg-white/[0.04] p-8 shadow-2xl backdrop-blur-xl"
      >
        <div className="mb-6 flex flex-col items-center text-center">
          <div className="mb-3 flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br from-brand-from to-brand-to shadow-lg shadow-brand-to/20">
            <Sparkles className="h-5 w-5 text-white" />
          </div>
          <h1 className="text-lg font-semibold text-white">Bon retour</h1>
          <p className="mt-1 text-sm text-white/50">Connecte-toi à ton espace de tâches</p>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-3">
          <Input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="border-white/10 bg-white/5 text-white placeholder:text-white/30 focus-visible:ring-brand-to"
          />
          <Input
            type="password"
            placeholder="Mot de passe"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            className="border-white/10 bg-white/5 text-white placeholder:text-white/30 focus-visible:ring-brand-to"
          />
          {error && (
            <motion.p
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              className="text-sm text-red-400"
            >
              {error}
            </motion.p>
          )}
          <Button
            type="submit"
            disabled={loading}
            className="mt-1 bg-gradient-to-r from-brand-from to-brand-to transition-transform hover:scale-[1.02] active:scale-[0.98]"
          >
            {loading ? "Connexion..." : "Se connecter"}
          </Button>
        </form>

        <p className="mt-5 text-center text-sm text-white/40">
          Pas de compte ?{" "}
          <Link to="/register" className="font-medium text-white/80 underline underline-offset-4 hover:text-white">
            Créer un compte
          </Link>
        </p>
      </motion.div>
    </div>
  );
}
