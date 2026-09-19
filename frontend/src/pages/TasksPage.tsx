import { useEffect, useState } from "react";
import { Plus, LogOut, Search } from "lucide-react";
import { api } from "@/lib/api";
import { useAuth } from "@/context/AuthContext";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { TaskForm } from "@/components/TaskForm";
import { TaskItem } from "@/components/TaskItem";
import type { Task, TaskInput, TaskStatus } from "@/types/task";

type StatusFilter = TaskStatus | "ALL";

export function TasksPage() {
  const { user, logout } = useAuth();
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("ALL");

  const [showForm, setShowForm] = useState(false);
  const [editingTask, setEditingTask] = useState<Task | null>(null);

  async function fetchTasks() {
    setLoading(true);
    setError(null);
    try {
      const params: Record<string, string> = {};
      if (statusFilter !== "ALL") params.status = statusFilter;
      if (search.trim()) params.search = search.trim();

      const { data } = await api.get<Task[]>("/api/tasks", { params });
      setTasks(data);
    } catch {
      setError("Impossible de charger les tâches");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    // Recherche/filtrage "live" avec un léger debounce pour éviter de spammer l'API.
    const timeout = setTimeout(fetchTasks, 300);
    return () => clearTimeout(timeout);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [search, statusFilter]);

  async function handleCreate(input: TaskInput) {
    await api.post("/api/tasks", input);
    setShowForm(false);
    await fetchTasks();
  }

  async function handleUpdate(input: TaskInput) {
    if (!editingTask) return;
    await api.put(`/api/tasks/${editingTask.id}`, input);
    setEditingTask(null);
    await fetchTasks();
  }

  async function handleDelete(id: number) {
    if (!confirm("Supprimer cette tâche ?")) return;
    await api.delete(`/api/tasks/${id}`);
    await fetchTasks();
  }

  return (
    <div className="min-h-screen bg-secondary/40">
      <header className="border-b border-border bg-background">
        <div className="container flex items-center justify-between py-4">
          <div>
            <h1 className="text-lg font-semibold">Task Manager</h1>
            {user && <p className="text-sm text-muted-foreground">Connecté en tant que {user.fullName}</p>}
          </div>
          <Button variant="outline" size="sm" onClick={logout}>
            <LogOut className="mr-2 h-4 w-4" />
            Déconnexion
          </Button>
        </div>
      </header>

      <main className="container flex flex-col gap-4 py-6">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div className="flex flex-1 gap-2">
            <div className="relative flex-1 max-w-sm">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                placeholder="Rechercher une tâche..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="pl-9"
              />
            </div>
            <Select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as StatusFilter)}
              className="w-40"
            >
              <option value="ALL">Tous statuts</option>
              <option value="TODO">À faire</option>
              <option value="IN_PROGRESS">En cours</option>
              <option value="DONE">Terminée</option>
            </Select>
          </div>
          <Button
            onClick={() => {
              setEditingTask(null);
              setShowForm(true);
            }}
          >
            <Plus className="mr-2 h-4 w-4" />
            Nouvelle tâche
          </Button>
        </div>

        {showForm && (
          <TaskForm
            onSubmit={handleCreate}
            onCancel={() => setShowForm(false)}
          />
        )}
        {editingTask && (
          <TaskForm
            initial={editingTask}
            onSubmit={handleUpdate}
            onCancel={() => setEditingTask(null)}
          />
        )}

        {loading && <p className="text-sm text-muted-foreground">Chargement...</p>}
        {error && <p className="text-sm text-destructive">{error}</p>}
        {!loading && !error && tasks.length === 0 && (
          <p className="py-8 text-center text-sm text-muted-foreground">
            Aucune tâche pour le moment. Crée-en une !
          </p>
        )}

        <div className="flex flex-col gap-2">
          {tasks.map((task) => (
            <TaskItem
              key={task.id}
              task={task}
              onEdit={() => {
                setShowForm(false);
                setEditingTask(task);
              }}
              onDelete={() => handleDelete(task.id)}
            />
          ))}
        </div>
      </main>
    </div>
  );
}
