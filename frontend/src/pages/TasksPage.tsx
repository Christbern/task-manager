import { useEffect, useMemo, useState } from "react";
import {
  DndContext,
  DragOverlay,
  PointerSensor,
  TouchSensor,
  useSensor,
  useSensors,
  type DragEndEvent,
  type DragStartEvent,
} from "@dnd-kit/core";
import { Plus, LogOut, Search, Sparkles } from "lucide-react";
import { api } from "@/lib/api";
import { useAuth } from "@/context/AuthContext";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Modal } from "@/components/Modal";
import { TaskForm } from "@/components/TaskForm";
import { TaskColumn } from "@/components/TaskColumn";
import { TaskCard } from "@/components/TaskCard";
import type { Task, TaskInput, TaskStatus } from "@/types/task";

const STATUSES: TaskStatus[] = ["TODO", "IN_PROGRESS", "DONE"];

export function TasksPage() {
  const { user, logout } = useAuth();
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");

  const [showForm, setShowForm] = useState(false);
  const [editingTask, setEditingTask] = useState<Task | null>(null);
  const [activeTask, setActiveTask] = useState<Task | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 6 } }),
    useSensor(TouchSensor, { activationConstraint: { delay: 150, tolerance: 8 } })
  );

  async function fetchTasks() {
    setLoading(true);
    setError(null);
    try {
      const { data } = await api.get<Task[]>("/api/tasks");
      setTasks(data);
    } catch {
      setError("Impossible de charger les tâches");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchTasks();
  }, []);

  const filteredTasks = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return tasks;
    return tasks.filter(
      (t) => t.title.toLowerCase().includes(q) || t.description?.toLowerCase().includes(q)
    );
  }, [search, tasks]);

  const tasksByStatus = useMemo(() => {
    const grouped: Record<TaskStatus, Task[]> = { TODO: [], IN_PROGRESS: [], DONE: [] };
    for (const t of filteredTasks) grouped[t.status].push(t);
    return grouped;
  }, [filteredTasks]);

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

  async function handleDelete(task: Task) {
    if (!confirm(`Supprimer "${task.title}" ?`)) return;
    setTasks((prev) => prev.filter((t) => t.id !== task.id));
    try {
      await api.delete(`/api/tasks/${task.id}`);
    } catch {
      fetchTasks(); // revert en cas d'échec
    }
  }

  function handleDragStart(event: DragStartEvent) {
    const task = tasks.find((t) => t.id === event.active.id);
    setActiveTask(task ?? null);
  }

  async function handleDragEnd(event: DragEndEvent) {
    const { active, over } = event;
    setActiveTask(null);
    if (!over) return;

    const task = tasks.find((t) => t.id === active.id);
    if (!task) return;

    // La cible est soit une colonne (id = statut), soit une carte (on prend son statut).
    const overTask = tasks.find((t) => t.id === over.id);
    const newStatus = (overTask ? overTask.status : (over.id as TaskStatus)) as TaskStatus;

    if (newStatus === task.status) return;

    // Mise à jour optimiste : l'UI réagit instantanément, on synchronise ensuite avec l'API.
    const previousTasks = tasks;
    setTasks((prev) => prev.map((t) => (t.id === task.id ? { ...t, status: newStatus } : t)));

    try {
      await api.put(`/api/tasks/${task.id}`, {
        title: task.title,
        description: task.description ?? "",
        status: newStatus,
      });
    } catch {
      setTasks(previousTasks); // rollback si l'API échoue
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-secondary/60 to-background">
      <header className="sticky top-0 z-30 border-b border-border/60 bg-background/80 backdrop-blur-md">
        <div className="container flex items-center justify-between py-4">
          <div className="flex items-center gap-2.5">
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-gradient-to-br from-brand-from to-brand-to text-white shadow-sm">
              <Sparkles className="h-4.5 w-4.5" />
            </div>
            <div>
              <h1 className="text-sm font-semibold leading-none">Task Manager</h1>
              {user && (
                <p className="mt-0.5 text-xs text-muted-foreground">Bonjour, {user.fullName.split(" ")[0]}</p>
              )}
            </div>
          </div>
          <Button variant="ghost" size="sm" onClick={logout}>
            <LogOut className="mr-2 h-4 w-4" />
            Déconnexion
          </Button>
        </div>
      </header>

      <main className="container flex flex-col gap-5 py-6">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div className="relative max-w-sm flex-1">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              placeholder="Rechercher une tâche..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-9"
            />
          </div>
          <Button
            onClick={() => {
              setEditingTask(null);
              setShowForm(true);
            }}
            className="bg-gradient-to-r from-brand-from to-brand-to shadow-sm transition-transform hover:scale-[1.02] active:scale-[0.98]"
          >
            <Plus className="mr-2 h-4 w-4" />
            Nouvelle tâche
          </Button>
        </div>

        {loading && (
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            {[0, 1, 2].map((i) => (
              <div key={i} className="h-40 animate-pulse rounded-2xl bg-muted/60" />
            ))}
          </div>
        )}
        {error && <p className="text-sm text-destructive">{error}</p>}

        {!loading && !error && (
          <DndContext sensors={sensors} onDragStart={handleDragStart} onDragEnd={handleDragEnd}>
            <div className="flex flex-col gap-4 sm:flex-row">
              {STATUSES.map((status) => (
                <TaskColumn
                  key={status}
                  status={status}
                  tasks={tasksByStatus[status]}
                  onEdit={(task) => {
                    setShowForm(false);
                    setEditingTask(task);
                  }}
                  onDelete={handleDelete}
                />
              ))}
            </div>

            <DragOverlay>
              {activeTask && (
                <TaskCard task={activeTask} onEdit={() => {}} onDelete={() => {}} isOverlay />
              )}
            </DragOverlay>
          </DndContext>
        )}
      </main>

      <Modal open={showForm || editingTask !== null} onClose={() => (showForm ? setShowForm(false) : setEditingTask(null))}>
        {showForm && <TaskForm onSubmit={handleCreate} onCancel={() => setShowForm(false)} />}
        {editingTask && (
          <TaskForm initial={editingTask} onSubmit={handleUpdate} onCancel={() => setEditingTask(null)} />
        )}
      </Modal>
    </div>
  );
}
