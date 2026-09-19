import { useState, type FormEvent } from "react";
import { X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select } from "@/components/ui/select";
import type { Task, TaskInput, TaskStatus } from "@/types/task";

interface TaskFormProps {
  initial?: Task;
  onSubmit: (input: TaskInput) => Promise<void>;
  onCancel: () => void;
}

const STATUS_LABELS: Record<TaskStatus, string> = {
  TODO: "À faire",
  IN_PROGRESS: "En cours",
  DONE: "Terminée",
};

export function TaskForm({ initial, onSubmit, onCancel }: TaskFormProps) {
  const [title, setTitle] = useState(initial?.title ?? "");
  const [description, setDescription] = useState(initial?.description ?? "");
  const [status, setStatus] = useState<TaskStatus>(initial?.status ?? "TODO");
  const [saving, setSaving] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setSaving(true);
    try {
      await onSubmit({ title, description, status });
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="overflow-hidden rounded-2xl border border-border bg-card shadow-2xl">
      <div className="flex items-center justify-between border-b border-border px-5 py-4">
        <h2 className="text-base font-semibold">{initial ? "Modifier la tâche" : "Nouvelle tâche"}</h2>
        <button
          onClick={onCancel}
          className="rounded-full p-1 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
          aria-label="Fermer"
        >
          <X className="h-4 w-4" />
        </button>
      </div>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4 p-5">
        <div className="flex flex-col gap-1.5">
          <label className="text-xs font-medium text-muted-foreground">Titre</label>
          <Input
            placeholder="Ex : Préparer la démo client"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            autoFocus
            required
          />
        </div>

        <div className="flex flex-col gap-1.5">
          <label className="text-xs font-medium text-muted-foreground">Description</label>
          <Textarea
            placeholder="Détails (optionnel)"
            value={description ?? ""}
            onChange={(e) => setDescription(e.target.value)}
            rows={3}
          />
        </div>

        <div className="flex flex-col gap-1.5">
          <label className="text-xs font-medium text-muted-foreground">Statut</label>
          <Select value={status} onChange={(e) => setStatus(e.target.value as TaskStatus)}>
            {(Object.keys(STATUS_LABELS) as TaskStatus[]).map((s) => (
              <option key={s} value={s}>
                {STATUS_LABELS[s]}
              </option>
            ))}
          </Select>
        </div>

        <div className="mt-1 flex justify-end gap-2">
          <Button type="button" variant="outline" onClick={onCancel} disabled={saving}>
            Annuler
          </Button>
          <Button type="submit" disabled={saving || !title.trim()}>
            {saving ? "Enregistrement..." : "Enregistrer"}
          </Button>
        </div>
      </form>
    </div>
  );
}
